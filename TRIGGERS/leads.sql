 -- TABLE -- 
  CREATE TABLE `banco`.`leads_count` (
  `idleads` INT NOT NULL AUTO_INCREMENT,
  `date` DATE NOT NULL,
  `menu` VARCHAR(255) NOT NULL,
  `comentario_text` TEXT NOT NULL,
  `feedback_text` VARCHAR(255) NOT NULL,
  `api_text` VARCHAR(255) NOT NULL,
  `interacao` INT NULL DEFAULT 0,
  `transbordo` INT NULL DEFAULT 0,
  `retencao` INT NULL DEFAULT 0,
  `comentario` INT NULL DEFAULT 0,
  `feedback` INT NULL DEFAULT 0,
  `api` INT NULL DEFAULT 0,
  `positivo` INT NULL DEFAULT 0,
   PRIMARY KEY (`idleads`));

-- TRIGGER --
USE banco;
DELIMITER |
CREATE TRIGGER tg_leads_in AFTER INSERT ON leads
FOR EACH ROW
BEGIN
	IF (SELECT EXISTS (
        SELECT * FROM banco.leads_count 
        WHERE date = NEW.lead_creation_day
        AND menu = CASE WHEN (NEW.escolher_opcao IS NOT NULL) THEN NEW.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (NEW.problemas_atendimento IS NOT NULL) THEN NEW.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (NEW.atendimento_foi_util IS NOT NULL) THEN NEW.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (NEW.erro_api IS NOT NULL) THEN NEW.erro_api ELSE '-' END)=0)
    THEN INSERT INTO banco.leads_count
    (date, menu, comentario_text, feedback_text, api_text)
    VALUES (NEW.lead_creation_day,
    CASE WHEN (NEW.escolher_opcao IS NOT NULL) THEN NEW.escolher_opcao ELSE '-' END,
    CASE WHEN (NEW.problemas_atendimento IS NOT NULL) THEN NEW.problemas_atendimento ELSE '-' END,
    CASE WHEN (NEW.atendimento_foi_util IS NOT NULL) THEN NEW.atendimento_foi_util ELSE '-' END,
    CASE WHEN (NEW.erro_api IS NOT NULL) THEN NEW.erro_api ELSE '-' END);
    END IF;

    IF (NEW.horario_atendimento = '1') 
    THEN UPDATE banco.leads_count
	    SET transbordo = transbordo + 1
    WHERE date = NEW.lead_creation_day
        AND menu = CASE WHEN (NEW.escolher_opcao IS NOT NULL) THEN NEW.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (NEW.problemas_atendimento IS NOT NULL) THEN NEW.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (NEW.atendimento_foi_util IS NOT NULL) THEN NEW.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (NEW.erro_api IS NOT NULL) THEN NEW.erro_api ELSE '-' END;
    END IF;	

    IF (NEW.escolher_opcao IS NOT NULL)
    THEN UPDATE banco.leads_count
	    SET interacao = interacao + 1
    WHERE date = NEW.lead_creation_day
        AND menu = CASE WHEN (NEW.escolher_opcao IS NOT NULL) THEN NEW.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (NEW.problemas_atendimento IS NOT NULL) THEN NEW.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (NEW.atendimento_foi_util IS NOT NULL) THEN NEW.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (NEW.erro_api IS NOT NULL) THEN NEW.erro_api ELSE '-' END;
    
    UPDATE banco.leads_count
	    SET retencao = 
        CASE WHEN (NEW.horario_atendimento = '1') THEN retencao + 0
        WHEN (NEW.atendimento_foi_util = 'Sim') THEN retencao + 1
        WHEN (NEW.problemas_atendimento IS NOT NULL) THEN retencao + 1
        WHEN (NEW.cod_empresa IS NOT NULL) THEN retencao + 1
        WHEN (NEW.endereco_registro = 'Sim') THEN retencao + 1
        WHEN (NEW.endereco_registro = 'Não') THEN retencao + 1
        WHEN (NEW.erro_api = '200') THEN retencao + 1
        ELSE retencao + 0 END
    WHERE date = NEW.lead_creation_day
        AND menu = CASE WHEN (NEW.escolher_opcao IS NOT NULL) THEN NEW.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (NEW.problemas_atendimento IS NOT NULL) THEN NEW.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (NEW.atendimento_foi_util IS NOT NULL) THEN NEW.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (NEW.erro_api IS NOT NULL) THEN NEW.erro_api ELSE '-' END;
    END IF;	

    IF (NEW.problemas_atendimento IS NOT NULL)  
    THEN UPDATE banco.leads_count
	    SET comentario = comentario + 1
    WHERE date = NEW.lead_creation_day
        AND menu = CASE WHEN (NEW.escolher_opcao IS NOT NULL) THEN NEW.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (NEW.problemas_atendimento IS NOT NULL) THEN NEW.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (NEW.atendimento_foi_util IS NOT NULL) THEN NEW.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (NEW.erro_api IS NOT NULL) THEN NEW.erro_api ELSE '-' END;
    END IF;	

    IF (NEW.atendimento_foi_util IS NOT NULL)  
    THEN UPDATE banco.leads_count
	    SET feedback = feedback + 1
    WHERE date = NEW.lead_creation_day
        AND menu = CASE WHEN (NEW.escolher_opcao IS NOT NULL) THEN NEW.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (NEW.problemas_atendimento IS NOT NULL) THEN NEW.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (NEW.atendimento_foi_util IS NOT NULL) THEN NEW.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (NEW.erro_api IS NOT NULL) THEN NEW.erro_api ELSE '-' END;
 
    UPDATE banco.leads_count
	    SET positivo = CASE
        WHEN (NEW.atendimento_foi_util = 'Sim') THEN positivo + 1
        ELSE positivo + 0 END
    WHERE date = NEW.lead_creation_day
        AND menu = CASE WHEN (NEW.escolher_opcao IS NOT NULL) THEN NEW.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (NEW.problemas_atendimento IS NOT NULL) THEN NEW.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (NEW.atendimento_foi_util IS NOT NULL) THEN NEW.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (NEW.erro_api IS NOT NULL) THEN NEW.erro_api ELSE '-' END;
    END IF;	

    IF (NEW.erro_api != '200')  
    THEN UPDATE banco.leads_count
	    SET api = api + 1
    WHERE date = NEW.lead_creation_day
        AND menu = CASE WHEN (NEW.escolher_opcao IS NOT NULL) THEN NEW.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (NEW.problemas_atendimento IS NOT NULL) THEN NEW.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (NEW.atendimento_foi_util IS NOT NULL) THEN NEW.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (NEW.erro_api IS NOT NULL) THEN NEW.erro_api ELSE '-' END;
    END IF;	    
END 

-- TRIGGER UPDATE --
USE banco;
DELIMITER |
CREATE TRIGGER tg_leads_up AFTER UPDATE ON leads
FOR EACH ROW
BEGIN
	IF (SELECT EXISTS (
        SELECT * FROM banco.leads_count 
        WHERE date = NEW.lead_creation_day
        AND menu = CASE WHEN (NEW.escolher_opcao IS NOT NULL) THEN NEW.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (NEW.problemas_atendimento IS NOT NULL) THEN NEW.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (NEW.atendimento_foi_util IS NOT NULL) THEN NEW.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (NEW.erro_api IS NOT NULL) THEN NEW.erro_api ELSE '-' END)=0)
    THEN INSERT INTO banco.leads_count
    (date, menu, comentario_text, feedback_text, api_text)
    VALUES (NEW.lead_creation_day,
    CASE WHEN (NEW.escolher_opcao IS NOT NULL) THEN NEW.escolher_opcao ELSE '-' END,
    CASE WHEN (NEW.problemas_atendimento IS NOT NULL) THEN NEW.problemas_atendimento ELSE '-' END,
    CASE WHEN (NEW.atendimento_foi_util IS NOT NULL) THEN NEW.atendimento_foi_util ELSE '-' END,
    CASE WHEN (NEW.erro_api IS NOT NULL) THEN NEW.erro_api ELSE '-' END);
    END IF;

    IF (NEW.horario_atendimento = '1') 
    THEN UPDATE banco.leads_count
	    SET transbordo = transbordo + 1
    WHERE date = NEW.lead_creation_day
        AND menu = CASE WHEN (NEW.escolher_opcao IS NOT NULL) THEN NEW.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (NEW.problemas_atendimento IS NOT NULL) THEN NEW.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (NEW.atendimento_foi_util IS NOT NULL) THEN NEW.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (NEW.erro_api IS NOT NULL) THEN NEW.erro_api ELSE '-' END;
    END IF;	

    IF (NEW.escolher_opcao IS NOT NULL)
    THEN UPDATE banco.leads_count
	    SET interacao = interacao + 1
    WHERE date = NEW.lead_creation_day
        AND menu = CASE WHEN (NEW.escolher_opcao IS NOT NULL) THEN NEW.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (NEW.problemas_atendimento IS NOT NULL) THEN NEW.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (NEW.atendimento_foi_util IS NOT NULL) THEN NEW.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (NEW.erro_api IS NOT NULL) THEN NEW.erro_api ELSE '-' END;
    
    UPDATE banco.leads_count
	    SET retencao = 
        CASE WHEN (NEW.horario_atendimento = '1') THEN retencao + 0
        WHEN (NEW.atendimento_foi_util = 'Sim') THEN retencao + 1
        WHEN (NEW.problemas_atendimento IS NOT NULL) THEN retencao + 1
        WHEN (NEW.cod_empresa IS NOT NULL) THEN retencao + 1
        WHEN (NEW.endereco_registro = 'Sim') THEN retencao + 1
        WHEN (NEW.endereco_registro = 'Não') THEN retencao + 1
        WHEN (NEW.erro_api = '200') THEN retencao + 1
        ELSE retencao + 0 END
    WHERE date = NEW.lead_creation_day
        AND menu = CASE WHEN (NEW.escolher_opcao IS NOT NULL) THEN NEW.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (NEW.problemas_atendimento IS NOT NULL) THEN NEW.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (NEW.atendimento_foi_util IS NOT NULL) THEN NEW.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (NEW.erro_api IS NOT NULL) THEN NEW.erro_api ELSE '-' END;
    END IF;	

    IF (NEW.problemas_atendimento IS NOT NULL)  
    THEN UPDATE banco.leads_count
	    SET comentario = comentario + 1
    WHERE date = NEW.lead_creation_day
        AND menu = CASE WHEN (NEW.escolher_opcao IS NOT NULL) THEN NEW.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (NEW.problemas_atendimento IS NOT NULL) THEN NEW.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (NEW.atendimento_foi_util IS NOT NULL) THEN NEW.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (NEW.erro_api IS NOT NULL) THEN NEW.erro_api ELSE '-' END;
    END IF;	

    IF (NEW.atendimento_foi_util IS NOT NULL)  
    THEN UPDATE banco.leads_count
	    SET feedback = feedback + 1
    WHERE date = NEW.lead_creation_day
        AND menu = CASE WHEN (NEW.escolher_opcao IS NOT NULL) THEN NEW.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (NEW.problemas_atendimento IS NOT NULL) THEN NEW.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (NEW.atendimento_foi_util IS NOT NULL) THEN NEW.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (NEW.erro_api IS NOT NULL) THEN NEW.erro_api ELSE '-' END;
 
    UPDATE banco.leads_count
	    SET positivo = CASE
        WHEN (NEW.atendimento_foi_util = 'Sim') THEN positivo + 1
        ELSE positivo + 0 END
    WHERE date = NEW.lead_creation_day
        AND menu = CASE WHEN (NEW.escolher_opcao IS NOT NULL) THEN NEW.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (NEW.problemas_atendimento IS NOT NULL) THEN NEW.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (NEW.atendimento_foi_util IS NOT NULL) THEN NEW.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (NEW.erro_api IS NOT NULL) THEN NEW.erro_api ELSE '-' END;
    END IF;	

    IF (NEW.erro_api != '200')  
    THEN UPDATE banco.leads_count
	    SET api = api + 1
    WHERE date = NEW.lead_creation_day
        AND menu = CASE WHEN (NEW.escolher_opcao IS NOT NULL) THEN NEW.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (NEW.problemas_atendimento IS NOT NULL) THEN NEW.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (NEW.atendimento_foi_util IS NOT NULL) THEN NEW.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (NEW.erro_api IS NOT NULL) THEN NEW.erro_api ELSE '-' END;
    END IF;

    IF (OLD.horario_atendimento = '1') 
    THEN UPDATE banco.leads_count
	    SET transbordo = transbordo - 1
    WHERE date = OLD.lead_creation_day
        AND menu = CASE WHEN (OLD.escolher_opcao IS NOT NULL) THEN OLD.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (OLD.problemas_atendimento IS NOT NULL) THEN OLD.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (OLD.atendimento_foi_util IS NOT NULL) THEN OLD.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (OLD.erro_api IS NOT NULL) THEN OLD.erro_api ELSE '-' END;
    END IF;	

    IF (OLD.escolher_opcao IS NOT NULL)
    THEN UPDATE banco.leads_count
	    SET interacao = interacao - 1
    WHERE date = OLD.lead_creation_day
        AND menu = CASE WHEN (OLD.escolher_opcao IS NOT NULL) THEN OLD.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (OLD.problemas_atendimento IS NOT NULL) THEN OLD.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (OLD.atendimento_foi_util IS NOT NULL) THEN OLD.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (OLD.erro_api IS NOT NULL) THEN OLD.erro_api ELSE '-' END;
    
    UPDATE banco.leads_count
	    SET retencao = 
        CASE WHEN (OLD.horario_atendimento = '1') THEN retencao - 0
        WHEN (OLD.atendimento_foi_util = 'Sim') THEN retencao - 1
        WHEN (OLD.problemas_atendimento IS NOT NULL) THEN retencao - 1
        WHEN (OLD.cod_empresa IS NOT NULL) THEN retencao - 1
        WHEN (OLD.endereco_registro = 'Sim') THEN retencao - 1
        WHEN (OLD.endereco_registro = 'Não') THEN retencao - 1
        WHEN (OLD.erro_api = '200') THEN retencao - 1
        ELSE retencao - 0 END
    WHERE date = OLD.lead_creation_day
        AND menu = CASE WHEN (OLD.escolher_opcao IS NOT NULL) THEN OLD.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (OLD.problemas_atendimento IS NOT NULL) THEN OLD.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (OLD.atendimento_foi_util IS NOT NULL) THEN OLD.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (OLD.erro_api IS NOT NULL) THEN OLD.erro_api ELSE '-' END;
    END IF;	

    IF (OLD.problemas_atendimento IS NOT NULL)  
    THEN UPDATE banco.leads_count
	    SET comentario = comentario - 1
    WHERE date = OLD.lead_creation_day
        AND menu = CASE WHEN (OLD.escolher_opcao IS NOT NULL) THEN OLD.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (OLD.problemas_atendimento IS NOT NULL) THEN OLD.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (OLD.atendimento_foi_util IS NOT NULL) THEN OLD.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (OLD.erro_api IS NOT NULL) THEN OLD.erro_api ELSE '-' END;
    END IF;	

    IF (OLD.atendimento_foi_util IS NOT NULL)  
    THEN UPDATE banco.leads_count
	    SET feedback = feedback - 1
    WHERE date = OLD.lead_creation_day
        AND menu = CASE WHEN (OLD.escolher_opcao IS NOT NULL) THEN OLD.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (OLD.problemas_atendimento IS NOT NULL) THEN OLD.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (OLD.atendimento_foi_util IS NOT NULL) THEN OLD.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (OLD.erro_api IS NOT NULL) THEN OLD.erro_api ELSE '-' END;
 
    UPDATE banco.leads_count
	    SET positivo = CASE
        WHEN (OLD.atendimento_foi_util = 'Sim') THEN positivo - 1
        ELSE positivo - 0 END
    WHERE date = OLD.lead_creation_day
        AND menu = CASE WHEN (OLD.escolher_opcao IS NOT NULL) THEN OLD.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (OLD.problemas_atendimento IS NOT NULL) THEN OLD.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (OLD.atendimento_foi_util IS NOT NULL) THEN OLD.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (OLD.erro_api IS NOT NULL) THEN OLD.erro_api ELSE '-' END;
    END IF;	

    IF (OLD.erro_api != '200')  
    THEN UPDATE banco.leads_count
	    SET api = api - 1
    WHERE date = OLD.lead_creation_day
        AND menu = CASE WHEN (OLD.escolher_opcao IS NOT NULL) THEN OLD.escolher_opcao ELSE '-' END
        AND comentario_text = CASE WHEN (OLD.problemas_atendimento IS NOT NULL) THEN OLD.problemas_atendimento ELSE '-' END
        AND feedback_text = CASE WHEN (OLD.atendimento_foi_util IS NOT NULL) THEN OLD.atendimento_foi_util ELSE '-' END
        AND api_text = CASE WHEN (OLD.erro_api IS NOT NULL) THEN OLD.erro_api ELSE '-' END;
    END IF;
END 

-- SELECT -- 
INSERT INTO banco.leads_count (`date`, `menu`, `comentario_text`, `feedback_text`,`api_text`,`interacao`,`transbordo`,
`retencao`,`comentario`,`feedback`,`api`,`positivo`)
SELECT c.date, c.menu, c.comentario_text, c.feedback_text, c.api_text, c.interacao, c.transbordo,
c.retencao, c.comentario, c.feedback, c.api, c.positivo
FROM 
(
SELECT 
	lead_creation_day AS date,
    (CASE WHEN (escolher_opcao IS NOT NULL) THEN escolher_opcao  ELSE '-' END) AS menu,
    (CASE WHEN (problemas_atendimento IS NOT NULL) THEN problemas_atendimento  ELSE '-' END) AS comentario_text,
    (CASE WHEN (atendimento_foi_util IS NOT NULL) THEN atendimento_foi_util  ELSE '-' END) AS feedback_text,
    (CASE WHEN (erro_api IS NOT NULL) THEN erro_api ELSE '-' END) AS api_text,
    SUM(CASE WHEN (escolher_opcao IS NOT NULL) THEN 1 ELSE 0 END) AS interacao,
    SUM(CASE WHEN (horario_atendimento = '1') THEN 1 ELSE 0 END) AS transbordo,
    SUM(CASE WHEN (horario_atendimento = '1') THEN 0
        WHEN (atendimento_foi_util = 'Sim') THEN 1
        WHEN (problemas_atendimento IS NOT NULL) THEN 1
        WHEN (cod_empresa IS NOT NULL) THEN 1
        WHEN (endereco_registro = 'Sim') THEN 1
        WHEN (endereco_registro = 'Não') THEN 1
        WHEN (erro_api = '200') THEN 1
        ELSE 0 END) AS retencao,
    SUM(CASE WHEN (problemas_atendimento IS NOT NULL) THEN 1 ELSE 0 END) AS comentario,
    SUM(CASE WHEN (atendimento_foi_util IS NOT NULL) THEN 1 ELSE 0 END) AS feedback,
    SUM(CASE WHEN (erro_api != '200') THEN 1 ELSE 0 END) AS api,
    SUM(CASE WHEN (atendimento_foi_util = 'Sim') THEN 1 ELSE 0 END) AS positivo
   	FROM banco.leads 
    WHERE lead_creation_day >= '2021-02-01' 
	GROUP BY date, menu, comentario_text, feedback_text, api_text) AS c
  ON DUPLICATE KEY UPDATE
        `date` = c.date,
        `menu` = c.menu,
        `comentario_text` = c.comentario_text,
        `feedback_text` = c.feedback_text,
        `api_text` = c.api_text,
        `interacao` = c.interacao,
        `transbordo` = c.transbordo,
        `retencao` = c.retencao,
        `comentario` = c.comentario,
        `feedback` = c.feedback,
        `api` = c.api,
        `positivo` = c.positivo;
