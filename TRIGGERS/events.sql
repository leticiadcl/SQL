-- TABLE -- 
  CREATE TABLE `altubot_amorsaude`.`events_count` (
  `idcount` INT NOT NULL AUTO_INCREMENT,
  `assistant_id` INT NOT NULL,
  `extra2` VARCHAR(255) NOT NULL,
  `date` DATE NOT NULL, 
  `transbordo` INT NULL DEFAULT 0,
  `promoters` INT NULL DEFAULT 0,
  `passives` INT NULL DEFAULT 0,
  `detractors` INT NULL DEFAULT 0,
  `totalnota` INT NULL DEFAULT 0,
  PRIMARY KEY (`idcount`));

-- TRIGGER -- 
USE altubot_amorsaude;
DELIMITER |
CREATE TRIGGER tg_amorsaude_events_in AFTER INSERT ON events
FOR EACH ROW
BEGIN
	IF ((NEW.assistant_id = '1') 
		AND (NEW.event_name IN ('horario_atendimento','pesquisa_satisfacao'))
		AND ((SELECT EXISTS(SELECT * FROM altubot_amorsaude.events_count
			WHERE assistant_id = NEW.assistant_id 
			AND date = NEW.date
			AND extra2 = CASE WHEN (NEW.extra2 IS NULL OR NEW.extra2 = '') THEN 'Clínica N/A' ELSE NEW.extra2 END))=0))

		THEN INSERT INTO altubot_amorsaude.events_count
		(assistant_id,date,extra2)
		VALUES (NEW.assistant_id,NEW.date,CASE WHEN (NEW.extra2 IS NULL OR NEW.extra2 = '') THEN 'Clínica N/A' ELSE NEW.extra2 END );
    END IF;

	IF ((NEW.assistant_id = '1') AND (NEW.event_name = 'horario_atendimento')) THEN 
		UPDATE altubot_amorsaude.events_count
		SET transbordo = transbordo + 1
		WHERE assistant_id = NEW.assistant_id 
			AND date = NEW.date
			AND extra2 = CASE WHEN (NEW.extra2 IS NULL OR NEW.extra2 = '') THEN 'Clínica N/A' ELSE NEW.extra2 END;

	ELSEIF ((NEW.assistant_id = '1') AND (NEW.event_name = 'pesquisa_satisfacao')) THEN 
		UPDATE altubot_amorsaude.events_count
		SET promoters = CASE 
		WHEN (NEW.extra1 IN ('10','9')) THEN promoters + 1
		ELSE promoters + 0
		END
		WHERE assistant_id = NEW.assistant_id 
			AND date = NEW.date
			AND extra2 = CASE WHEN (NEW.extra2 IS NULL OR NEW.extra2 = '') THEN 'Clínica N/A' ELSE NEW.extra2 END;

		UPDATE altubot_amorsaude.events_count
		SET passives = CASE 
		WHEN (NEW.extra1 IN ('7','8')) THEN passives + 1
		ELSE passives + 0
		END
		WHERE assistant_id = NEW.assistant_id 
			AND date = NEW.date
			AND extra2 = CASE WHEN (NEW.extra2 IS NULL OR NEW.extra2 = '') THEN 'Clínica N/A' ELSE NEW.extra2 END;

		UPDATE altubot_amorsaude.events_count
		SET detractors = CASE 
		WHEN (NEW.extra1 IN ('6','5','4','3','2','1','0')) THEN detractors + 1
		ELSE detractors + 0
		END
		WHERE assistant_id = NEW.assistant_id 
			AND date = NEW.date
			AND extra2 = CASE WHEN (NEW.extra2 IS NULL OR NEW.extra2 = '') THEN 'Clínica N/A' ELSE NEW.extra2 END;

		UPDATE altubot_amorsaude.events_count
		SET totalnota = CASE 
		WHEN (NEW.extra1 IN ('10','9','8','7','6','5','4','3','2','1','0')) THEN totalnota + 1
        ELSE totalnota + 0 END
		WHERE assistant_id = NEW.assistant_id 
			AND date = NEW.date
			AND extra2 = CASE WHEN (NEW.extra2 IS NULL OR NEW.extra2 = '') THEN 'Clínica N/A' ELSE NEW.extra2 END;
	END IF;
END 

-- SELECT -- 
INSERT INTO altubot_amorsaude.events_count (`date`, `assistant_id`, `extra2`, `transbordo`, `promoters`, `passives`, `detractors`, `totalnota`)
SELECT c.date, c.assistant_id, (CASE WHEN (c.extra2 IS NULL OR c.extra2 = '') THEN 'Clínica N/A' ELSE c.extra2 END) AS extra2, 
 c.transbordo, c.promoters, c.passives, c.detractors, c.totalnota
FROM
(
	SELECT 
		d.date,
		d.assistant_id,
		(CASE WHEN (d.extra2 IS NULL OR d.extra2 = '') THEN 'Clínica N/A' ELSE d.extra2 END) AS extra2,
        SUM(CASE WHEN (d.event_name = 'horario_atendimento') THEN 1 ELSE 0 END) AS transbordo,
		SUM(CASE WHEN ((d.event_name = 'pesquisa_satisfacao') AND (d.extra1 IN ('9','10'))) THEN 1 ELSE 0 END) AS promoters,
		SUM(CASE WHEN ((d.event_name = 'pesquisa_satisfacao') AND (d.extra1 IN ('7','8'))) THEN 1 ELSE 0 END) AS passives,
		SUM(CASE WHEN ((d.event_name = 'pesquisa_satisfacao') AND (d.extra1 IN ('0','1','2','3','4','5','6'))) THEN 1 ELSE 0 END) AS detractors,
		SUM(CASE WHEN ((d.event_name = 'pesquisa_satisfacao') AND (d.extra1 IN ('0','1','2','3','4','5','6','7','8','9','10'))) THEN 1 ELSE 0 END) AS totalnota
	FROM altubot_amorsaude.events AS d
		WHERE d.assistant_id = '1' 
			AND d.event_name IN ('horario_atendimento','pesquisa_satisfacao')
			AND d.date = '2021-05-18'
		GROUP BY d.date, extra2 ) as c
	ON DUPLICATE KEY UPDATE
		`date` = c.date,
		`assistant_id` = c.assistant_id,
		`extra2` = c.extra2,
		`transbordo` = c.transbordo,
		`promoters` = c.promoters,
		`passives` = c.passives,
		`detractors` = c.detractors,
		`totalnota` = c.totalnota;
