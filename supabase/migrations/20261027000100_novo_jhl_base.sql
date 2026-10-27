create extension if not exists pgcrypto;

create table if not exists public.colaboradores(
 id uuid primary key default gen_random_uuid(), nome text not null, cpf text, rg text,
 data_nascimento date, data_admissao date, data_desligamento date, cargo text, departamento text,
 telefone text, email text, endereco text, remuneracao numeric(12,2), vinculo text default 'Empregado',
 situacao text not null default 'ativo', nome_pai text, nome_mae text, filhos jsonb not null default '[]'::jsonb,
 jornada text, dados_bancarios jsonb, observacoes text, motivo_desligamento text,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create unique index if not exists colaboradores_cpf_unique on public.colaboradores(cpf) where cpf is not null;

create table if not exists public.user_roles(
 user_id uuid primary key references auth.users(id) on delete cascade,
 role text not null default 'user', created_at timestamptz not null default now()
);
create table if not exists public.historico(
 id uuid primary key default gen_random_uuid(), user_id uuid references auth.users(id),
 acao text not null, entidade text, entidade_id uuid, detalhes jsonb, created_at timestamptz not null default now()
);
create table if not exists public.colaborador_documentos(
 id uuid primary key default gen_random_uuid(), colaborador_id uuid not null references public.colaboradores(id) on delete cascade,
 nome_arquivo text not null, caminho text not null, categoria text, created_at timestamptz not null default now()
);
create table if not exists public.clientes(
 id uuid primary key default gen_random_uuid(), nome text not null, razao_social text, nome_fantasia text,
 documento text, contato text, telefone text, email text, responsavel text, endereco text,
 observacoes text, ativo boolean not null default true, created_at timestamptz not null default now()
);
create table if not exists public.lancamentos(
 id uuid primary key default gen_random_uuid(), competencia date not null, cliente_id uuid references public.clientes(id),
 status text not null default 'rascunho', dados jsonb not null default '{}'::jsonb,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.lancamento_historico(
 id uuid primary key default gen_random_uuid(), lancamento_id uuid not null references public.lancamentos(id) on delete cascade,
 versao integer not null, status text, dados jsonb not null default '{}'::jsonb, motivo text,
 alterado_por uuid references auth.users(id), created_at timestamptz not null default now(),
 unique(lancamento_id,versao)
);
create table if not exists public.documentos_gerados(
 id uuid primary key default gen_random_uuid(), colaborador_id uuid references public.colaboradores(id) on delete set null,
 nome_arquivo text, conteudo_html text, created_at timestamptz not null default now()
);

alter table public.colaboradores enable row level security;
alter table public.user_roles enable row level security;
alter table public.historico enable row level security;
alter table public.colaborador_documentos enable row level security;
alter table public.clientes enable row level security;
alter table public.lancamentos enable row level security;
alter table public.lancamento_historico enable row level security;
alter table public.documentos_gerados enable row level security;

create or replace function public.is_member(uid uuid) returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.user_roles where user_id=uid) $$;

drop policy if exists colaboradores_member on public.colaboradores;
create policy colaboradores_member on public.colaboradores for all to authenticated using(public.is_member(auth.uid())) with check(public.is_member(auth.uid()));
drop policy if exists documentos_member on public.colaborador_documentos;
create policy documentos_member on public.colaborador_documentos for all to authenticated using(public.is_member(auth.uid())) with check(public.is_member(auth.uid()));
drop policy if exists clientes_member on public.clientes;
create policy clientes_member on public.clientes for all to authenticated using(public.is_member(auth.uid())) with check(public.is_member(auth.uid()));
drop policy if exists lancamentos_member on public.lancamentos;
create policy lancamentos_member on public.lancamentos for all to authenticated using(public.is_member(auth.uid())) with check(public.is_member(auth.uid()));
drop policy if exists historico_member on public.historico;
create policy historico_member on public.historico for all to authenticated using(public.is_member(auth.uid())) with check(user_id=auth.uid());
drop policy if exists user_roles_self on public.user_roles;
create policy user_roles_self on public.user_roles for select to authenticated using(user_id=auth.uid());
drop policy if exists lancamento_historico_member on public.lancamento_historico;
create policy lancamento_historico_member on public.lancamento_historico for all to authenticated using(public.is_member(auth.uid())) with check(public.is_member(auth.uid()));
drop policy if exists documentos_gerados_member on public.documentos_gerados;
create policy documentos_gerados_member on public.documentos_gerados for all to authenticated using(public.is_member(auth.uid())) with check(public.is_member(auth.uid()));