SELECT 
    (DATE_FORMAT(c.created_at,"%d/%m/%Y")) AS Data,
    (DATE_FORMAT(c.created_at,"%H:%i:%s")) AS Hora,
    c.contact_id AS Id,
    (case when c.name is not null then c.name else '' end) AS Name, 
	(case when c.phone is not null then c.phone else '' end) AS Phone,
    (case when (k.assunto is not null) then k.assunto else 'Sem assunto' end) as Assunto,
    (case when (k.assunto_1tentativa is not null) then k.assunto_1tentativa end) as assunto_1tentativa,
    (CASE WHEN (f.Origem IS NULL) THEN 'AcessosWhats' ELSE f.Origem END)  AS Origem, 
    1 AS Acessos,
	(CASE WHEN (d.protocolos = '1' OR g.Transbordo IS NULL) THEN 0 ELSE g.Transbordo END) AS Transbordo,
    (CASE WHEN (d.protocolos IS NULL) THEN 0 ELSE d.protocolos END) AS Protocolos,
    (CASE WHEN (d.numeroprotocolos IS NULL) THEN '' ELSE d.numeroprotocolos END) AS numeroProtocolos,
    (CASE WHEN (h.Nota IS NULL) THEN '' ELSE h.Nota END) AS Nota,
    (CASE WHEN (h.comentarioNota IS NULL) THEN '' ELSE h.comentarioNota END) AS comentarioNota,
    (CASE WHEN (i.falha_api IS NULL) THEN '' ELSE i.falha_api END) AS field1_falha_api,
    (CASE WHEN (d.protocolos = '1' OR g.assuntoTransbordo IS NULL OR j.transbordoDetalhado IS NULL) THEN '' ELSE g.assuntoTransbordo END) AS assuntoTransbordo,
    (CASE WHEN (d.protocolos = '1' OR g.assuntoTransbordo IS NULL OR j.transbordoDetalhado IS NULL) THEN '' ELSE j.transbordoDetalhado END) AS transbordoDetalhado,
    (CASE WHEN (i.extra1 IS NULL) THEN '' ELSE i.extra1 END) AS extra1_falha_api,
    (CASE WHEN (i.extra2 IS NULL) THEN '' ELSE i.extra2 END) AS extra2_falha_api,
    (CASE WHEN (i.details IS NULL) THEN '' ELSE i.details END) AS details_falha_api,
	(CASE WHEN (n.inicio_atendimento IS NULL) THEN '' ELSE n.inicio_atendimento END) AS inicio_atendimento,
    (CASE WHEN (n.fim_atendimento IS NULL) THEN '' ELSE n.fim_atendimento END) AS fim_atendimento,
    (CASE WHEN (o.inicio_transbordo IS NULL) THEN '' ELSE o.inicio_transbordo END) AS inicio_transbordo,
    (CASE WHEN (o.fim_transbordo IS NULL) THEN '' ELSE o.fim_transbordo END) AS fim_transbordo,
    (CASE WHEN (i.falha_api2 IS NULL) THEN '' ELSE i.falha_api2 END) AS field2_falha_api,
    (CASE WHEN (l.cpf IS NULL) THEN '' ELSE l.cpf  END) AS cpf,
    (CASE WHEN (m.data_nascimento IS NULL) THEN '' ELSE m.data_nascimento END) AS data_nascimento,
    (CASE WHEN (d.autosservico IS NULL) THEN '' ELSE d.autosservico END) AS Autosservico,
    p.opção_sinistro
FROM 
(
	(
        SELECT 
            MIN(a.created_at) AS created_at,
            a.contact_id,
            a.date,
            b.name,
            b.phone
        FROM banco.events AS a LEFT JOIN banco.contacts AS b ON a.contact_id = b.id
        WHERE a.assistant_id = '1'
            AND a.event_name = 'novo_atendimento'
            AND a.date between '2021-10-01' and '2021-10-31'
            AND b.environment = 'prod'
        GROUP BY a.created_at, a.contact_id
    ) AS c
    LEFT JOIN
	(
        SELECT 
            MIN(CASE WHEN a1.event_name = 'novo_atendimento' THEN a1.created_at END) AS created_at,
            a1.contact_id,
            MAX(CASE WHEN (b1.event_name = 'autosservico') THEN 1 ELSE 0 END) AS protocolos,
            (CASE WHEN (b1.event_name = 'autosservico' AND b1.extra1 IN ('1','0')) THEN b1.extra1 ELSE '' END) AS autosservico,
            MAX(CASE WHEN (b1.event_name = 'assistencia_acidente_solicitada') THEN b1.extra2 END) AS numeroprotocolos
        FROM banco.events AS a1 LEFT JOIN banco.events AS b1 ON a1.contact_id = b1.contact_id AND b1.created_at > a1.created_at
        WHERE a1.assistant_id = '1'
            AND a1.event_name = 'novo_atendimento'
            AND b1.event_name IN ('autosservico','assistencia_acidente_solicitada')
            AND a1.date between '2021-10-01' and '2021-10-31'
        GROUP BY a1.created_at, a1.contact_id
    ) AS d ON d.contact_id = c.contact_id AND d.created_at = c.created_at
    LEFT JOIN
	(
        SELECT 
            MIN(CASE WHEN a3.event_name = 'novo_atendimento' THEN a3.created_at END) AS created_at,
            a3.contact_id,
            (CASE WHEN (b3.event_name = 'inicio_outbound' AND b3.extra1 = 'sem_outbound') THEN 'AcessosWhats'
			    WHEN (b3.event_name = 'inicio_outbound' AND b3.extra1 = 'com_outbound') THEN 'AcessosUra' ELSE 'AcessosUra' END) AS origem
        FROM banco.events AS a3 LEFT JOIN banco.events AS b3 ON a3.contact_id = b3.contact_id AND b3.created_at >= a3.created_at
        WHERE a3.assistant_id = '1'
            AND a3.event_name = 'novo_atendimento'
            AND b3.event_name = 'inicio_outbound'
            AND a3.date between '2021-10-01' and '2021-10-31'
        GROUP BY a3.created_at, a3.contact_id
    ) AS f ON f.contact_id = c.contact_id AND f.created_at = c.created_at 
    LEFT JOIN
	(
        SELECT 
            MIN(created_at) AS created_at,
            date,
            contact_id,
            MAX(CASE WHEN (event_name = 'transbordo') THEN 1 ELSE 0 END) AS Transbordo,
            MAX(CASE WHEN (event_name = 'transbordo' AND extra1 IS NOT NULL) THEN extra1 END) AS assuntoTransbordo
        FROM banco.events
        WHERE assistant_id = '1'
            AND event_name = 'transbordo'
            AND date between '2021-10-01' and '2021-10-31'
        GROUP BY created_at, contact_id
    ) AS g ON c.contact_id = g.contact_id AND g.created_at >= c.created_at AND g.date = c.date
    LEFT JOIN
	(
        SELECT 
            MIN(created_at) AS created_at,
            date,
            contact_id,
            (CASE WHEN (event_name = 'pesquisa_satisfacao') THEN extra1 END) AS Nota,
            (CASE WHEN (event_name = 'comentario') THEN extra1 END) AS comentarioNota
        FROM banco.events
        WHERE assistant_id = '1'
            AND event_name IN ('pesquisa_satisfacao','comentario')
            AND date between '2021-10-01' and '2021-10-31'
        GROUP BY created_at, contact_id
    ) AS h ON c.contact_id = h.contact_id AND h.created_at >= c.created_at AND h.date = c.date
    LEFT JOIN
    (
    SELECT 
        MIN(CASE WHEN a4.event_name = 'novo_atendimento' THEN a4.created_at END) AS created_at,
        a4.contact_id,
        (CASE WHEN (b4.event_name = 'falha_api') THEN b4.details ->> "$.field1" END) AS falha_api,
        (CASE WHEN (b4.event_name = 'falha_api') THEN b4.details ->> "$.field2" END) AS falha_api2,
        b4.extra1,
        b4.extra2,
        b4.details
    FROM banco.events AS a4 LEFT JOIN banco.events AS b4 ON a4.contact_id = b4.contact_id AND b4.created_at > a4.created_at
    WHERE a4.assistant_id = '1'
        AND a4.event_name = 'novo_atendimento'
        AND b4.event_name = 'falha_api'
        AND a4.date between '2021-10-01' and '2021-10-31'
    GROUP BY a4.created_at, a4.contact_id
    ) AS i ON i.contact_id = c.contact_id AND i.created_at = c.created_at 
    LEFT JOIN
    (
    SELECT 
        MIN(CASE WHEN a5.event_name = 'novo_atendimento' THEN a5.created_at END) AS created_at,
        a5.contact_id,
        (CASE WHEN (b5.event_name = 'transbordo_detalhado' AND b5.extra1 IS NOT NULL ) THEN b5.extra1 ELSE '-' END) AS transbordoDetalhado
    FROM banco.events AS a5 LEFT JOIN banco.events AS b5 ON a5.contact_id = b5.contact_id AND b5.created_at > a5.created_at
    WHERE a5.assistant_id = '1'
        AND a5.event_name = 'novo_atendimento'
        AND b5.event_name = 'transbordo_detalhado'
        AND a5.date between '2021-10-01' and '2021-10-31'
    GROUP BY a5.created_at, a5.contact_id
    ) AS j ON j.contact_id = c.contact_id AND j.created_at = c.created_at 
    LEFT JOIN
    (
        SELECT 
        MIN(CASE WHEN b2.event_name = 'novo_atendimento' THEN b2.created_at END) AS created_at,
        b2.contact_id,
        MAX(CASE WHEN (b3.event_name = 'menu_principal') THEN b3.extra1 else 'Sem Assunto' END) as assunto,
        (SELECT CASE WHEN (a1.event_name = 'menu_principal' and a1.extra2 = b2.extra1) THEN a1.extra1 END
        FROM banco.events AS a1
        WHERE a1.assistant_id = '1' AND a1.event_name = 'menu_principal' AND a1.contact_id = b2.contact_id AND a1.created_at > b2.created_at
        and a1.extra2 = b2.extra1
        ORDER BY a1.created_at asc limit 1) AS assunto_1tentativa,
        (SELECT CASE WHEN (a2.event_name = 'menu_principal' and a2.extra2 = b2.extra1) THEN a2.extra1 END
        FROM banco.events AS a2
        WHERE a2.assistant_id = '1' AND a2.event_name = 'menu_principal' AND a2.contact_id = b2.contact_id AND a2.created_at > b2.created_at
        and a2.extra2 = b2.extra1
        ORDER BY a2.created_at desc limit 1) AS assunto_2tentativa   
    FROM banco.events AS b2 LEFT JOIN banco.events AS b3 ON b2.contact_id = b3.contact_id AND b3.created_at > b2.created_at
    WHERE b2.assistant_id = '1' 
        AND b2.event_name = 'novo_atendimento'
        and b3.event_name = 'menu_principal'
        and b2.date between '2021-10-01' and '2021-10-31'
    GROUP BY b2.created_at, b2.contact_id
    )as k ON k.contact_id = c.contact_id AND k.created_at = c.created_at 
    LEFT JOIN
    (
       SELECT 
        contact_id,
        (CASE WHEN (event_name = 'cpf_digitado') THEN extra2 ELSE '' END) AS cpf
    FROM banco.events 
    WHERE assistant_id = '1'
        AND event_name = 'cpf_digitado'
        AND date between '2021-10-01' and '2021-10-31'
    GROUP BY contact_id
    )as l ON l.contact_id = c.contact_id 
    LEFT JOIN 
    (
    SELECT 
        contact_id,
        (CASE WHEN event_name = 'data_nascimento_digitada' THEN extra2 ELSE '' END) AS data_nascimento
    FROM banco.events 
    WHERE assistant_id = '1'
        AND event_name = 'data_nascimento_digitada'
        AND date between '2021-10-01' and '2021-10-31'
    GROUP BY contact_id
    ) As m ON m.contact_id = c.contact_id  
    LEFT JOIN 
    (
    SELECT 
        contact_id,
        (CASE WHEN event_name = 'tma' THEN extra1 ELSE '' END) AS inicio_atendimento,
        (CASE WHEN event_name = 'tma' THEN extra2 ELSE '' END) AS fim_atendimento
    FROM banco.events 
    WHERE assistant_id = '1'
        AND event_name = 'tma'
        AND date between '2021-10-01' and '2021-10-31'
    GROUP BY contact_id
    ) As n ON n.contact_id = c.contact_id  
    LEFT JOIN 
    (
    SELECT 
        contact_id,
        (CASE WHEN event_name = 'tma_transbordo' THEN extra1 ELSE '' END) AS inicio_transbordo,
        (CASE WHEN event_name = 'tma_transbordo' THEN extra2 ELSE '' END) AS fim_transbordo
    FROM banco.events 
    WHERE assistant_id = '1'
        AND event_name = 'tma_transbordo'
        AND date between '2021-10-01' and '2021-10-31'
    GROUP BY contact_id
    ) As o ON o.contact_id = c.contact_id  
	LEFT JOIN 
    (
    SELECT 
        contact_id,
        (CASE WHEN event_name = 'opção_sinistro' THEN extra1 ELSE '' END) AS opção_sinistro
    FROM banco.events 
    WHERE assistant_id = '1'
        AND event_name = 'opção_sinistro'
        AND date between '2021-10-01' and '2021-10-31'
    GROUP BY contact_id
    ) As p ON p.contact_id = c.contact_id  
) GROUP BY Data,Hora,Id


