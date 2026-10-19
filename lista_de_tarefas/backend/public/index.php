<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');

function responder(int $status, array $dados = []): void
{
    http_response_code($status);
    echo json_encode($dados, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function corpoJson(): array
{
    $dados = json_decode(file_get_contents('php://input'), true);
    if (!is_array($dados)) {
        responder(400, ['erro' => 'O corpo da requisição deve ser um JSON válido.']);
    }

    return $dados;
}

function tarefa(array $registro): array
{
    return [
        'id' => (int) $registro['id'],
        'descricao' => $registro['descricao'],
        'concluida' => (bool) $registro['concluida'],
    ];
}

$host = getenv('DB_HOST');
$porta = getenv('DB_PORT') ?: '3306';
$banco = getenv('DB_NAME');
$usuario = getenv('DB_USER');
$senha = getenv('DB_PASSWORD');

if (!$host || !$banco || !$usuario || $senha === false) {
    responder(500, ['erro' => 'Configure DB_HOST, DB_NAME, DB_USER e DB_PASSWORD.']);
}

try {
    $pdo = new PDO(
        "mysql:host={$host};port={$porta};dbname={$banco};charset=utf8mb4",
        $usuario,
        $senha,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ],
    );
} catch (PDOException $erro) {
    error_log($erro->getMessage());
    responder(500, ['erro' => 'Não foi possível conectar ao banco de dados.']);
}

$metodo = $_SERVER['REQUEST_METHOD'];
$caminho = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$caminho = trim($caminho ?? '', '/');

try {
    if ($caminho === 'tarefas' && $metodo === 'GET') {
        $registros = $pdo->query(
            'SELECT id, descricao, concluida FROM tarefas ORDER BY id DESC',
        )->fetchAll();
        responder(200, array_map('tarefa', $registros));
    }

    if ($caminho === 'tarefas' && $metodo === 'POST') {
        $dados = corpoJson();
        $descricao = $dados['descricao'] ?? null;
        if (!is_string($descricao)) {
            responder(422, ['erro' => 'A descrição deve ser um texto.']);
        }
        $descricao = trim($descricao);
        if ($descricao === '' || preg_match_all('/./us', $descricao) > 255) {
            responder(422, ['erro' => 'A descrição deve ter entre 1 e 255 caracteres.']);
        }

        $consulta = $pdo->prepare(
            'INSERT INTO tarefas (descricao) VALUES (:descricao)',
        );
        $consulta->execute(['descricao' => $descricao]);
        $consulta = $pdo->prepare(
            'SELECT id, descricao, concluida FROM tarefas WHERE id = :id',
        );
        $consulta->execute(['id' => $pdo->lastInsertId()]);
        responder(201, tarefa($consulta->fetch()));
    }

    if (preg_match('#^tarefas/([1-9][0-9]*)$#', $caminho, $partes)) {
        $id = (int) $partes[1];

        if ($metodo === 'PATCH') {
            $dados = corpoJson();
            if (!array_key_exists('concluida', $dados) || !is_bool($dados['concluida'])) {
                responder(422, ['erro' => 'O campo concluída deve ser verdadeiro ou falso.']);
            }

            $consulta = $pdo->prepare(
                'UPDATE tarefas SET concluida = :concluida WHERE id = :id',
            );
            $consulta->bindValue(':concluida', $dados['concluida'], PDO::PARAM_BOOL);
            $consulta->bindValue(':id', $id, PDO::PARAM_INT);
            $consulta->execute();
            $consulta = $pdo->prepare(
                'SELECT id, descricao, concluida FROM tarefas WHERE id = :id',
            );
            $consulta->execute(['id' => $id]);
            $registro = $consulta->fetch();
            if (!$registro) {
                responder(404, ['erro' => 'Tarefa não encontrada.']);
            }
            responder(200, tarefa($registro));
        }

        if ($metodo === 'DELETE') {
            $consulta = $pdo->prepare('DELETE FROM tarefas WHERE id = :id');
            $consulta->execute(['id' => $id]);
            if ($consulta->rowCount() === 0) {
                responder(404, ['erro' => 'Tarefa não encontrada.']);
            }
            http_response_code(204);
            exit;
        }
    }

    responder(404, ['erro' => 'Rota não encontrada.']);
} catch (PDOException $erro) {
    error_log($erro->getMessage());
    responder(500, ['erro' => 'Não foi possível concluir a operação.']);
}
