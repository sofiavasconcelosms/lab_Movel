# Lista de tarefas

Aplicativo Flutter para cadastrar tarefas, marcar as concluídas e removê-las.
Os dados são persistidos em MySQL por uma API REST em PHP.

## Requisitos

- Flutter e Dart compatíveis com `pubspec.yaml`
- PHP 8 ou superior com as extensões PDO e PDO MySQL
- MySQL

## Configurar o MySQL e a API

Na raiz do repositório, execute o script `lista_de_tarefas/backend/schema.sql`
no MySQL:

```sql
SOURCE lista_de_tarefas/backend/schema.sql;
```

Configure as variáveis de ambiente `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`
e `DB_PASSWORD` com os dados do seu banco. O `DB_NAME` criado pelo script é
`lista_de_tarefas`. Exemplo no PowerShell:

```powershell
$env:DB_HOST = '127.0.0.1'
$env:DB_PORT = '3306'
$env:DB_NAME = 'lista_de_tarefas'
$env:DB_USER = 'root'
$env:DB_PASSWORD = 'sua-senha-local'
```

Na pasta `lista_de_tarefas`, inicie a API:

```powershell
php -S 0.0.0.0:8000 -t backend/public
```

O emulador Android usa `http://10.0.2.2:8000` por padrão para acessar a API
executada no computador. Para um dispositivo físico, informe o endereço IP do
computador na rede local:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8000
```

Substitua o IP pelo endereço correto. A conexão HTTP sem criptografia é
permitida somente na configuração Android de debug. Em produção, publique a API
com HTTPS e informe sua URL usando `API_BASE_URL`. Esta atividade não inclui
autenticação; não exponha a API publicamente sem adicionar controle de acesso.

## Executar e testar

Na pasta `lista_de_tarefas`, execute:

```powershell
flutter pub get
flutter run
flutter test
```

## API

- `GET /tarefas`: lista as tarefas.
- `POST /tarefas` com `{"descricao":"Estudar Flutter"}`: cadastra uma tarefa.
- `PATCH /tarefas/{id}` com `{"concluida":true}`: atualiza sua conclusão.
- `DELETE /tarefas/{id}`: remove uma tarefa.
