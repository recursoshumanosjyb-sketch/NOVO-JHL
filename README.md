# NOVO JHL

Sistema de Gestão Integrada da JHL, construído diretamente no GitHub e independente do Lovable.

## Base atual

- React + TypeScript + Vite
- Supabase para banco e autenticação
- RLS preparado para membros autenticados
- Estrutura de colaboradores, demitidos, clientes, lançamentos, histórico, documentos e documentos gerados
- Dashboard inicial
- Consulta de colaboradores conectada ao Supabase
- GitHub Actions para validação

## Configuração

Use o arquivo .env.example como referência para configurar o Supabase.

As migrations ficam em supabase/migrations.

Dados pessoais e PDFs de colaboradores não devem ser armazenados no repositório GitHub. Use o banco e o Storage privado do Supabase.
