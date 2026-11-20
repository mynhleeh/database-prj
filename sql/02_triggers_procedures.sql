-- A34Build DB (MySQL 8.0+ / InnoDB / utf8mb4) - E24-Class 5, Group 5
-- File 02: Triggers (Rules 1-7)

USE A34Build_DB;

DELIMITER //

-- Rule 1: Phase budget total <= Project EstimatedBudget
DROP TRIGGER IF EXISTS TRG_CHECK_PHASE_BUDGET_INSERT //
CREATE TRIGGER TRG_CHECK_PHASE_BUDGET_INSERT
BEFORE INSERT ON PROJECT_PHASE
FOR EACH ROW
BEGIN
    DECLARE v_project_budget DECIMAL(15,2);
    DECLARE v_current_phases_total DECIMAL(15,2);

    SELECT EstimatedBudget INTO v_project_budget
    FROM PROJECT
    WHERE ProjectID = NEW.ProjectID;

    SELECT COALESCE(SUM(PhaseBudget), 0.00) INTO v_current_phases_total
    FROM PROJECT_PHASE
    WHERE ProjectID = NEW.ProjectID;

    IF (v_current_phases_total + NEW.PhaseBudget) > v_project_budget THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 1 Violation: Total PhaseBudget cannot exceed Project EstimatedBudget.';
    END IF;
END //

DROP TRIGGER IF EXISTS TRG_CHECK_PHASE_BUDGET_UPDATE //
CREATE TRIGGER TRG_CHECK_PHASE_BUDGET_UPDATE
BEFORE UPDATE ON PROJECT_PHASE
FOR EACH ROW
BEGIN
    DECLARE v_project_budget DECIMAL(15,2);
    DECLARE v_other_phases_total DECIMAL(15,2);

    SELECT EstimatedBudget INTO v_project_budget
    FROM PROJECT
    WHERE ProjectID = NEW.ProjectID;

    SELECT COALESCE(SUM(PhaseBudget), 0.00) INTO v_other_phases_total
    FROM PROJECT_PHASE
    WHERE ProjectID = NEW.ProjectID
      AND PhaseNumber <> OLD.PhaseNumber;

    IF (v_other_phases_total + NEW.PhaseBudget) > v_project_budget THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 1 Violation: Total PhaseBudget cannot exceed Project EstimatedBudget.';
    END IF;
END //

-- Rule 2: Non-overlapping equipment deployment intervals
DROP TRIGGER IF EXISTS TRG_CHECK_EQUIPMENT_OVERLAP_INSERT //
CREATE TRIGGER TRG_CHECK_EQUIPMENT_OVERLAP_INSERT
BEFORE INSERT ON EQUIPMENT_DEPLOYMENT
FOR EACH ROW
BEGIN
    DECLARE v_overlap_count INT;

    SELECT COUNT(*) INTO v_overlap_count
    FROM EQUIPMENT_DEPLOYMENT
    WHERE EquipmentID = NEW.EquipmentID
      AND (NEW.DeploymentStartDate <= DeploymentEndDate)
      AND (NEW.DeploymentEndDate >= DeploymentStartDate);

    IF v_overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 2 Violation: Equipment deployment interval overlaps with an existing deployment.';
    END IF;
END //

DROP TRIGGER IF EXISTS TRG_CHECK_EQUIPMENT_OVERLAP_UPDATE //
CREATE TRIGGER TRG_CHECK_EQUIPMENT_OVERLAP_UPDATE
BEFORE UPDATE ON EQUIPMENT_DEPLOYMENT
FOR EACH ROW
BEGIN
    DECLARE v_overlap_count INT;

    SELECT COUNT(*) INTO v_overlap_count
    FROM EQUIPMENT_DEPLOYMENT
    WHERE EquipmentID = NEW.EquipmentID
      AND DeploymentStartDate <> OLD.DeploymentStartDate
      AND (NEW.DeploymentStartDate <= DeploymentEndDate)
      AND (NEW.DeploymentEndDate >= DeploymentStartDate);

    IF v_overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 2 Violation: Equipment deployment interval overlaps with an existing deployment.';
    END IF;
END //

-- Rule 3: Operator certification must match equipment category
DROP TRIGGER IF EXISTS TRG_CHECK_OPERATOR_CERT_INSERT //
CREATE TRIGGER TRG_CHECK_OPERATOR_CERT_INSERT
BEFORE INSERT ON EQUIPMENT_DEPLOYMENT
FOR EACH ROW
BEGIN
    DECLARE v_cert_count INT;
    DECLARE v_equip_category VARCHAR(100);

    SELECT Category INTO v_equip_category
    FROM EQUIPMENT
    WHERE EquipmentID = NEW.EquipmentID;

    SELECT COUNT(*) INTO v_cert_count
    FROM EMPLOYEE_CERTIFICATION
    WHERE EmpID = NEW.OperatorEmpID
      AND (Certification LIKE CONCAT('%', v_equip_category, '%') 
           OR Certification LIKE '%Heavy Equipment%' 
           OR Certification LIKE '%Master Operator%');

    IF v_cert_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 3 Violation: Assigned operator lacks valid certification for this equipment category.';
    END IF;
END //

DROP TRIGGER IF EXISTS TRG_CHECK_OPERATOR_CERT_UPDATE //
CREATE TRIGGER TRG_CHECK_OPERATOR_CERT_UPDATE
BEFORE UPDATE ON EQUIPMENT_DEPLOYMENT
FOR EACH ROW
BEGIN
    DECLARE v_cert_count INT;
    DECLARE v_equip_category VARCHAR(100);

    SELECT Category INTO v_equip_category
    FROM EQUIPMENT
    WHERE EquipmentID = NEW.EquipmentID;

    SELECT COUNT(*) INTO v_cert_count
    FROM EMPLOYEE_CERTIFICATION
    WHERE EmpID = NEW.OperatorEmpID
      AND (Certification LIKE CONCAT('%', v_equip_category, '%') 
           OR Certification LIKE '%Heavy Equipment%' 
           OR Certification LIKE '%Master Operator%');

    IF v_cert_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 3 Violation: Assigned operator lacks valid certification for this equipment category.';
    END IF;
END //

-- Rule 4: Max 12.00 logged hours per employee per day
DROP TRIGGER IF EXISTS TRG_CHECK_DAILY_HOURS_INSERT //
CREATE TRIGGER TRG_CHECK_DAILY_HOURS_INSERT
BEFORE INSERT ON WORKS_ON_TASK
FOR EACH ROW
BEGIN
    DECLARE v_daily_total DECIMAL(5,2);

    SELECT COALESCE(SUM(HoursLogged), 0.00) INTO v_daily_total
    FROM WORKS_ON_TASK
    WHERE EmpID = NEW.EmpID
      AND AssignedDate = NEW.AssignedDate;

    IF (v_daily_total + NEW.HoursLogged) > 12.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 4 Violation: Worker logged hours exceed statutory limit of 12 hours per calendar day.';
    END IF;
END //

DROP TRIGGER IF EXISTS TRG_CHECK_DAILY_HOURS_UPDATE //
CREATE TRIGGER TRG_CHECK_DAILY_HOURS_UPDATE
BEFORE UPDATE ON WORKS_ON_TASK
FOR EACH ROW
BEGIN
    DECLARE v_other_hours DECIMAL(5,2);

    SELECT COALESCE(SUM(HoursLogged), 0.00) INTO v_other_hours
    FROM WORKS_ON_TASK
    WHERE EmpID = NEW.EmpID
      AND AssignedDate = NEW.AssignedDate
      AND TaskID <> OLD.TaskID;

    IF (v_other_hours + NEW.HoursLogged) > 12.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 4 Violation: Worker logged hours exceed statutory limit of 12 hours per calendar day.';
    END IF;
END //

-- Rule 5: Acyclic task precedence DAG on PRECEDES
DROP TRIGGER IF EXISTS TRG_CHECK_PRECEDES_DAG //
CREATE TRIGGER TRG_CHECK_PRECEDES_DAG
BEFORE INSERT ON PRECEDES
FOR EACH ROW
BEGIN
    DECLARE v_cycle_detected INT DEFAULT 0;

    -- Self-loop check (enforced here; MySQL Error 3823 forbids table CHECK on FK column)
    IF NEW.PredecessorTaskID = NEW.SuccessorTaskID THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 5 Violation: Self-loop precedence is strictly prohibited.';
    END IF;

    -- Detect path from SuccessorTaskID to PredecessorTaskID via recursive CTE
    WITH RECURSIVE PrecedenceChain AS (
        SELECT SuccessorTaskID AS CurrentTask
        FROM PRECEDES
        WHERE PredecessorTaskID = NEW.SuccessorTaskID
        
        UNION ALL
        
        SELECT p.SuccessorTaskID
        FROM PRECEDES p
        INNER JOIN PrecedenceChain pc ON p.PredecessorTaskID = pc.CurrentTask
    )
    SELECT COUNT(*) INTO v_cycle_detected
    FROM PrecedenceChain
    WHERE CurrentTask = NEW.PredecessorTaskID;

    IF v_cycle_detected > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 5 Violation: Circular dependency detected in task precedence (Violates DAG).';
    END IF;
END //

-- Rule 6: Prevent stock overdraft & auto-update inventory
DROP TRIGGER IF EXISTS TRG_CHECK_MATERIAL_STOCK_INSERT //
CREATE TRIGGER TRG_CHECK_MATERIAL_STOCK_INSERT
BEFORE INSERT ON MATERIAL_USAGE
FOR EACH ROW
BEGIN
    DECLARE v_available_stock DECIMAL(12,2);

    SELECT CurrentStockQuantity INTO v_available_stock
    FROM SITE_INVENTORY
    WHERE SiteID = NEW.SiteID
      AND MaterialID = NEW.MaterialID;

    IF v_available_stock IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 6 Violation: Material is not registered in site inventory.';
    ELSEIF v_available_stock < NEW.UsedQuantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 6 Violation: Material usage quantity exceeds current on-site stock quantity.';
    END IF;
END //

DROP TRIGGER IF EXISTS TRG_DEDUCT_MATERIAL_STOCK_AFTER_INSERT //
CREATE TRIGGER TRG_DEDUCT_MATERIAL_STOCK_AFTER_INSERT
AFTER INSERT ON MATERIAL_USAGE
FOR EACH ROW
BEGIN
    UPDATE SITE_INVENTORY
    SET CurrentStockQuantity = CurrentStockQuantity - NEW.UsedQuantity
    WHERE SiteID = NEW.SiteID
      AND MaterialID = NEW.MaterialID;
END //

-- Auto-replenish stock when delivery dispatch arrives
DROP TRIGGER IF EXISTS TRG_ADD_STOCK_ON_DELIVERY //
CREATE TRIGGER TRG_ADD_STOCK_ON_DELIVERY
AFTER INSERT ON DELIVERY_DISPATCH
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Received' THEN
        -- Insert or Update inventory record
        INSERT INTO SITE_INVENTORY (SiteID, MaterialID, CurrentStockQuantity, MinStock, ReorderQuantity)
        VALUES (NEW.SiteID, NEW.MaterialID, NEW.DeliveredQuantity, 50.00, 200.00)
        ON DUPLICATE KEY UPDATE CurrentStockQuantity = CurrentStockQuantity + NEW.DeliveredQuantity;
    END IF;
END //

-- Rule 7: At most one Active project per director
DROP TRIGGER IF EXISTS TRG_CHECK_DIRECTOR_ACTIVE_PROJECT_INSERT //
CREATE TRIGGER TRG_CHECK_DIRECTOR_ACTIVE_PROJECT_INSERT
BEFORE INSERT ON PROJECT
FOR EACH ROW
BEGIN
    DECLARE v_active_projects INT;

    IF NEW.Status = 'Active' THEN
        SELECT COUNT(*) INTO v_active_projects
        FROM PROJECT
        WHERE DirectorEmpID = NEW.DirectorEmpID
          AND Status = 'Active';

        IF v_active_projects > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Rule 7 Violation: Site director is already managing an active project.';
        END IF;
    END IF;
END //

DROP TRIGGER IF EXISTS TRG_CHECK_DIRECTOR_ACTIVE_PROJECT_UPDATE //
CREATE TRIGGER TRG_CHECK_DIRECTOR_ACTIVE_PROJECT_UPDATE
BEFORE UPDATE ON PROJECT
FOR EACH ROW
BEGIN
    DECLARE v_active_projects INT;

    IF NEW.Status = 'Active' THEN
        SELECT COUNT(*) INTO v_active_projects
        FROM PROJECT
        WHERE DirectorEmpID = NEW.DirectorEmpID
          AND Status = 'Active'
          AND ProjectID <> OLD.ProjectID;

        IF v_active_projects > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Rule 7 Violation: Site director is already managing an active project.';
        END IF;
    END IF;
END //

DELIMITER ;
