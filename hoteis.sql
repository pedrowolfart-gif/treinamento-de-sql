CREATE TABLE hospedes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

create table categorias (
id serial primary key,
nome varchar (150) not null,
valor_diario_base decimal(10, 2) not null check (valor_diario_base > 0)
)

create table acomodacoes(
id serial primary key,
categoria_id int not null,
numero_quarto varchar(4) not null,
bloco varchar (100) not null, 
capacidade_maxima int not null check (capacidade_maxima > 0),
disponivel boolean default true,

constraint fk_acomodacoes_categorias foreign key (categoria_id) references categorias(id)
);

create table reservas(
id serial primary key,
hospedes_id int not null,
data_criacao timestamp default current_timestamp,
status varchar(20) default 'confirmada' check (status in ('confirmada','cancelada','finalizada')),
constraint fk_reservas_hospedes foreign key (hospedes_id) references hospedes(id) on delete cascade
);

CREATE TABLE itens_reserva (
    id SERIAL PRIMARY KEY,
    reserva_id INT NOT NULL,
    acomodacao_id INT NOT NULL,
    quantidade_diarias INT NOT NULL CHECK (quantidade_diarias > 0),
    valor_diaria_aplicado DECIMAL(10,2) NOT NULL CHECK (valor_diaria_aplicado > 0),
    taxa_turismo DECIMAL(10,2) DEFAULT 0.00 CHECK (taxa_turismo >= 0),
    CONSTRAINT fk_itens_reservas FOREIGN KEY (reserva_id) REFERENCES reservas(id) ON DELETE CASCADE,
    CONSTRAINT fk_itens_acomodacoes FOREIGN KEY (acomodacao_id) REFERENCES acomodacoes(id) ON DELETE CASCADE
);

insert into hospedes (nome, email, cpf , telefone) values
('pedro','pedrowolfart@gmail.com','13142150942','48996943164'),
('ana','ana@gmail.com','12150030012','48984449155'),
('anderso','anderson@gmail.com','01655544433','48912341234')

insert into categorias (nome, valor_diario_base) values
('stabdard', 120.00),
('Luxo Vista Mar', 250.00),
('Suíte Presidencial', 750.00 )

insert into acomodacoes (categoria_id, numero_quarto, bloco, capacidade_maxima) values
(1,'101','bloco a', 2),
(2,'204','bloco b', 5),
(3,'501','bloco c', 5)

INSERT INTO reservas (hospedes_id, status) VALUES
(1, 'confirmada'),  
(2, 'confirmada'),  
(3, 'confirmada')

INSERT INTO itens_reserva (reserva_id, acomodacao_id, quantidade_diarias, valor_diaria_aplicado, taxa_turismo ) VALUES
(5, 3, 3, 750.00, 50.00),
(6, 2, 2, 550.00, 20.00),
(7, 1, 10, 120.00, 10.00)

CREATE OR REPLACE VIEW vw_acomodacoes_custo_estimado AS
SELECT 
    a.numero_quarto,
    a.bloco,
    c.nome AS categoria_nome,
    ROUND(c.valor_diario_base * 1.10, 2) AS valor_diario_ajustado
FROM acomodacoes a
JOIN categorias c ON a.categoria_id = c.id
ORDER BY valor_diario_ajustado DESC;

create or replace view vw_reservas_confirmadas as select
h.nome as hospedes_nome,
h.cpf,
a.numero_quarto,
ir.quantidade_diarias,
r.data_criacao
from reservas r join hospedes h on r.hospedes_id = h.id
join itens_reserva ir on ir.reserva_id = r.id
join acomodacoes a on ir.acomodacao_id = a.id
where r.status = 'confirmado';

create or replace view vw_hospedes_vip as select 
h.nome as hospedes_nome,
count (r.id) as qtd_reservas_confirmadas,
sum ((ir.valor_diaria_aplicado * ir.quantidade_diarias) + ir.taxa_turismo) as total_investido
from hospedes h
join reservas r on r.hospedes_id = h.id
join itens_reserva ir on ir.reserva_id = r.id
where r.status = 'Confirmada'
group by h.id, h.nome
having sum ((ir.valor_diaria_aplicado * ir.quantidade_diarias) + ir.taxa_turismo) > 1000.00;

