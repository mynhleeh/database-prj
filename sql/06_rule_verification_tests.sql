-- =============================================================================
-- DATABASE DESIGN TERM PROJECT (PHASE 3) - E24-Class 5, Group 5
-- Topic: Multi-Project Construction Enterprise Database System (A34Build)
-- Target DBMS: MySQL 8.0+ (Storage Engine: InnoDB, Charset: utf8mb4)
-- File 06: Business Rule Verification & Trigger Test Queries (Rules 1 - 8)
-- References: deliverables/sql/02_triggers_procedures.sql & report_p3_v2
-- =============================================================================
-- HUONG DAN CHAY TRONG MYSQL WORKBENCH:
--   1. Cac cau truy van [AUDIT / SELECT] co the chay lien tiep de kiem tra
--      du lieu hien tai trong database co dang tuan thu du 8 rule hay khong.
--   2. Cac cau lenh [TEST VI PHAM] (Negative Tests) se co tinh kich hoat
--      Trigger va tra ve Error Code: 1644 (SQLSTATE '45000'). Hay boi den
--      tung cau lenh va bam Ctrl+Enter de kiem chung tung rule (tranh bam
--      Execute All vi MySQL Workbench se dung o loi dau tien).
--   3. Cac cau [TEST HOP LE] co thay doi du lieu (Rule 6, Rule 8) di kem
--      lenh CLEANUP de khoi phuc du lieu mau ve trang thai sach.
-- =============================================================================

USE A34Build_DB;

-- =============================================================================
-- RULE 1: Phase Budget Accumulation Constraint
-- Quy tac: Tong PhaseBudget cua cac giai doan khong duoc vuot qua EstimatedBudget.
-- Triggers: TRG_CHECK_PHASE_BUDGET_INSERT, TRG_CHECK_PHASE_BUDGET_UPDATE
-- =============================================================================

-- [1.1 - AUDIT] Kiem tra tong ngan sach cac giai doan so voi ngan sach du an
SELECT 
    p.ProjectID,
    p.ProjectName,
    p.EstimatedBudget,
    COALESCE(SUM(pp.PhaseBudget), 0.00) AS TotalPhaseBudget,
    (p.EstimatedBudget - COALESCE(SUM(pp.PhaseBudget), 0.00)) AS RemainingBudget,
    CASE 
        WHEN COALESCE(SUM(pp.PhaseBudget), 0.00) <= p.EstimatedBudget THEN 'PASS'
        ELSE 'VIOLATION'
    END AS Rule1_Status
FROM PROJECT p
LEFT JOIN PROJECT_PHASE pp ON p.ProjectID = pp.ProjectID
GROUP BY p.ProjectID, p.ProjectName, p.EstimatedBudget
ORDER BY p.ProjectID;

-- [1.2 - TEST VI PHAM INSERT] (Theo proof r1 trong bao cao)
-- PRJ001 co EstimatedBudget = 180B; hien tai 35B + 80B + 50B = 165B (con du 15B).
-- Them Phase 4 voi 30B => 195B > 180B.
-- Ky vong: Error Code: 1644. Rule 1 Violation: Total PhaseBudget cannot exceed Project EstimatedBudget.
INSERT INTO PROJECT_PHASE (ProjectID, PhaseNumber, PhaseName, PhaseBudget, StartDate, ScheduledEndDate, Status)
VALUES ('PRJ001', 4, 'Test Invalid Phase Budget Overrun', 30000000000.00, '2025-07-01', '2025-09-30', 'Pending');

-- [1.3 - TEST VI PHAM UPDATE]
-- Tang PhaseBudget cua Phase 3 (PRJ001) tu 50B len 70B => 35B + 80B + 70B = 185B > 180B.
-- Ky vong: Error Code: 1644. Rule 1 Violation: Total PhaseBudget cannot exceed Project EstimatedBudget.
UPDATE PROJECT_PHASE
SET PhaseBudget = 70000000000.00
WHERE ProjectID = 'PRJ001' AND PhaseNumber = 3;


-- =============================================================================
-- RULE 2: Machinery Schedule Non-Overlapping Constraint
-- Quy tac: Cung mot thiet bi khong duoc dieu dong chong cheo ngay giua cac site.
-- Triggers: TRG_CHECK_EQUIPMENT_OVERLAP_INSERT, TRG_CHECK_EQUIPMENT_OVERLAP_UPDATE
-- =============================================================================

-- [2.1 - AUDIT] Liet ke cac cap lich dieu dong cua cung thiet bi bi chong cheo (neu co)
SELECT 
    ed1.EquipmentID,
    ed1.SiteID AS Site1,
    ed1.DeploymentStartDate AS Start1,
    ed1.DeploymentEndDate AS End1,
    ed2.SiteID AS Site2,
    ed2.DeploymentStartDate AS Start2,
    ed2.DeploymentEndDate AS End2
FROM EQUIPMENT_DEPLOYMENT ed1
JOIN EQUIPMENT_DEPLOYMENT ed2
    ON ed1.EquipmentID = ed2.EquipmentID
   AND ed1.DeploymentStartDate < ed2.DeploymentStartDate
   AND ed1.DeploymentEndDate >= ed2.DeploymentStartDate;

-- [2.2 - TEST VI PHAM INSERT] (Theo proof r2 trong bao cao)
-- EQP001 da duoc dieu dong 2024-01-10 -> 2024-06-30 tai SITE01.
-- Chen lich 2024-03-01 -> 2024-03-15 tai SITE02 (EMP010 co du chung chi Tower Crane).
-- Ky vong: Error Code: 1644. Rule 2 Violation: Equipment deployment interval overlaps with an existing deployment.
INSERT INTO EQUIPMENT_DEPLOYMENT (EquipmentID, DeploymentStartDate, DeploymentEndDate, OperatingHours, SiteID, OperatorEmpID)
VALUES ('EQP001', '2024-03-01', '2024-03-15', 50.00, 'SITE02', 'EMP010');

-- [2.3 - TEST VI PHAM UPDATE]
-- Keo dai DeploymentEndDate cua dot 1 (2024-01-10 -> 2024-06-30) sang 2024-07-15, de len dot 2 (bat dau 2024-07-01).
-- Ky vong: Error Code: 1644. Rule 2 Violation: Equipment deployment interval overlaps with an existing deployment.
UPDATE EQUIPMENT_DEPLOYMENT
SET DeploymentEndDate = '2024-07-15'
WHERE EquipmentID = 'EQP001' AND DeploymentStartDate = '2024-01-10';


-- =============================================================================
-- RULE 3: Equipment Operator Certification Rule
-- Quy tac: Nhan vien van hanh phai co chung chi phu hop Category cua thiet bi
--          (hoac chung chi 'Heavy Equipment' / 'Master Operator').
-- Triggers: TRG_CHECK_OPERATOR_CERT_INSERT, TRG_CHECK_OPERATOR_CERT_UPDATE
-- =============================================================================

-- [3.1 - AUDIT] Kiem tra tat ca cac dot dieu dong hien co xem nguoi van hanh co du chung chi khong
SELECT 
    ed.EquipmentID,
    eq.EquipmentName,
    eq.Category AS RequiredCategory,
    ed.DeploymentStartDate,
    ed.OperatorEmpID,
    CONCAT(e.FirstName, ' ', e.LastName) AS OperatorName,
    GROUP_CONCAT(ec.Certification SEPARATOR '; ') AS OperatorCertifications,
    CASE 
        WHEN EXISTS (
            SELECT 1
            FROM EMPLOYEE_CERTIFICATION ec2
            WHERE ec2.EmpID = ed.OperatorEmpID
              AND (ec2.Certification LIKE CONCAT('%', eq.Category, '%')
                   OR ec2.Certification LIKE '%Heavy Equipment%'
                   OR ec2.Certification LIKE '%Master Operator%')
        ) THEN 'PASS'
        ELSE 'VIOLATION'
    END AS Rule3_Status
FROM EQUIPMENT_DEPLOYMENT ed
JOIN EQUIPMENT eq ON ed.EquipmentID = eq.EquipmentID
JOIN EMPLOYEE e ON ed.OperatorEmpID = e.EmpID
LEFT JOIN EMPLOYEE_CERTIFICATION ec ON e.EmpID = ec.EmpID
GROUP BY ed.EquipmentID, eq.EquipmentName, eq.Category, ed.DeploymentStartDate, ed.OperatorEmpID, e.FirstName, e.LastName;

-- [3.2 - TEST VI PHAM INSERT]
-- EQP002 thuoc Category 'Heavy Crane' (chua co lich dieu dong -> khong vuong Rule 2).
-- EMP014 (Site Electrician) chi co chung chi 'High Voltage Industrial Electrician Level 4'.
-- Ky vong: Error Code: 1644. Rule 3 Violation: Assigned operator lacks valid certification for this equipment category.
INSERT INTO EQUIPMENT_DEPLOYMENT (EquipmentID, DeploymentStartDate, DeploymentEndDate, OperatingHours, SiteID, OperatorEmpID)
VALUES ('EQP002', '2025-01-05', '2025-01-20', 40.00, 'SITE01', 'EMP014');

-- [3.3 - TEST VI PHAM UPDATE]
-- Doi nguoi van hanh may dao EQP003 ('Excavator') sang EMP014 (tho dien, khong co chung chi Excavator).
-- Ky vong: Error Code: 1644. Rule 3 Violation: Assigned operator lacks valid certification for this equipment category.
UPDATE EQUIPMENT_DEPLOYMENT
SET OperatorEmpID = 'EMP014'
WHERE EquipmentID = 'EQP003' AND DeploymentStartDate = '2024-04-15';


-- =============================================================================
-- RULE 4: Maximum Daily Working Hour Limit (<= 12 Hours per Calendar Day)
-- Quy tac: Tong HoursLogged cua mot nhan vien trong 1 ngay khong qua 12.00 gio.
-- Triggers: TRG_CHECK_DAILY_HOURS_INSERT, TRG_CHECK_DAILY_HOURS_UPDATE
-- =============================================================================

-- [4.1 - AUDIT] Thong ke tong gio lam theo ngay cua tung nhan vien
SELECT 
    w.EmpID,
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
    w.AssignedDate,
    SUM(w.HoursLogged) AS TotalDailyHours,
    CASE 
        WHEN SUM(w.HoursLogged) <= 12.00 THEN 'PASS'
        ELSE 'VIOLATION'
    END AS Rule4_Status
FROM WORKS_ON_TASK w
JOIN EMPLOYEE e ON w.EmpID = e.EmpID
GROUP BY w.EmpID, e.FirstName, e.LastName, w.AssignedDate
ORDER BY w.AssignedDate, TotalDailyHours DESC;

-- [4.2 - TEST VI PHAM INSERT] (Tuong ung proof r3 trong bao cao)
-- Ngay 2024-10-15, EMP008 da ghi nhan 8.00 gio cho TSK103.
-- Chen them 5.00 gio o TSK102 cung ngay 2024-10-15 => 8.00 + 5.00 = 13.00 > 12.00.
-- (Luu y: dung TSK102 thay vi TSK104 de khong trung PK (EMP008, TSK104) co san o ngay 2024-10-16)
-- Ky vong: Error Code: 1644. Rule 4 Violation: Worker logged hours exceed statutory limit of 12 hours per calendar day.
INSERT INTO WORKS_ON_TASK (EmpID, TaskID, HoursLogged, RoleDescription, AssignedDate)
VALUES ('EMP008', 'TSK102', 5.00, 'Overtime Work', '2024-10-15');

-- [4.3 - TEST VI PHAM UPDATE]
-- Cap nhat gio lam ngay 2024-10-15 cua EMP008 o TSK103 len 12.50 gio.
-- Ky vong: Error Code: 1644. Rule 4 Violation: Worker logged hours exceed statutory limit of 12 hours per calendar day.
UPDATE WORKS_ON_TASK
SET HoursLogged = 12.50
WHERE EmpID = 'EMP008' AND TaskID = 'TSK103';


-- =============================================================================
-- RULE 5: Acyclic Dependency Constraint (DAG on PRECEDES)
-- Quy tac: Do thi phu thuoc cong viec khong duoc co self-loop hoac chu trinh.
-- Trigger: TRG_CHECK_PRECEDES_DAG (BEFORE INSERT ON PRECEDES)
-- =============================================================================

-- [5.1 - AUDIT] Hien thi cac chuoi phu thuoc cong viec va kiem tra chu trinh hien huu
WITH RECURSIVE TaskPaths AS (
    SELECT 
        PredecessorTaskID AS StartTask,
        SuccessorTaskID AS CurrentTask,
        CAST(CONCAT(PredecessorTaskID, ' -> ', SuccessorTaskID) AS CHAR(500)) AS DependencyPath,
        1 AS Depth,
        (PredecessorTaskID = SuccessorTaskID) AS HasCycle
    FROM PRECEDES
    UNION ALL
    SELECT 
        tp.StartTask,
        p.SuccessorTaskID,
        CONCAT(tp.DependencyPath, ' -> ', p.SuccessorTaskID),
        tp.Depth + 1,
        (p.SuccessorTaskID = tp.StartTask)
    FROM TaskPaths tp
    JOIN PRECEDES p ON tp.CurrentTask = p.PredecessorTaskID
    WHERE tp.HasCycle = 0 AND tp.Depth < 20
)
SELECT StartTask, CurrentTask, Depth, DependencyPath, HasCycle
FROM TaskPaths
ORDER BY StartTask, Depth;

-- [5.2 - TEST VI PHAM SELF-LOOP]
-- Ky vong: Error Code: 1644. Rule 5 Violation: Self-loop precedence is strictly prohibited.
INSERT INTO PRECEDES (PredecessorTaskID, SuccessorTaskID)
VALUES ('TSK101', 'TSK101');

-- [5.3 - TEST VI PHAM CHU TRINH DA BUOC] (Theo proof r4/r5 trong bao cao)
-- Hien co: TSK101 -> TSK102 -> TSK103.
-- Chen TSK103 -> TSK101 se tao vong lap TSK101 -> TSK102 -> TSK103 -> TSK101.
-- Ky vong: Error Code: 1644. Rule 5 Violation: Circular dependency detected in task precedence (Violates DAG).
INSERT INTO PRECEDES (PredecessorTaskID, SuccessorTaskID)
VALUES ('TSK103', 'TSK101');


-- =============================================================================
-- RULE 6: Material Stock Overdraft Prevention & Inventory Auto-Update
-- Quy tac:
--   - Khong duoc xuat vat tu chua co trong kho hoac vuot qua CurrentStockQuantity.
--   - Tu dong tru kho sau khi INSERT MATERIAL_USAGE.
--   - Tu dong cong kho sau khi INSERT DELIVERY_DISPATCH voi Status = 'Received'.
-- Triggers: TRG_CHECK_MATERIAL_STOCK_INSERT, TRG_DEDUCT_MATERIAL_STOCK_AFTER_INSERT,
--           TRG_ADD_STOCK_ON_DELIVERY
-- =============================================================================

-- [6.1 - AUDIT] Xem ton kho hien tai tai cac cong truong
SELECT 
    si.SiteID,
    ps.SiteName,
    si.MaterialID,
    m.MaterialName,
    m.Unit,
    si.CurrentStockQuantity,
    si.MinStock,
    si.ReorderQuantity
FROM SITE_INVENTORY si
JOIN PROJECT_SITE ps ON si.SiteID = ps.SiteID
JOIN MATERIAL m ON si.MaterialID = m.MaterialID
ORDER BY si.SiteID, si.MaterialID;

-- [6.2 - TEST VI PHAM XUAT QUA TON KHO] (Theo proof r6 trong bao cao)
-- SITE01 dang co 145.00 tan MAT001. Xuat 9999.00 tan se bi chan.
-- Ky vong: Error Code: 1644. Rule 6 Violation: Material usage quantity exceeds current on-site stock quantity.
INSERT INTO MATERIAL_USAGE (TaskID, MaterialID, SiteID, UsageDate, UsedQuantity)
VALUES ('TSK103', 'MAT001', 'SITE01', '2024-11-15', 9999.00);

-- [6.3 - TEST VI PHAM VAT TU CHUA DANG KY TRONG KHO SITE]
-- MAT002 chua co trong SITE_INVENTORY cua SITE01.
-- Ky vong: Error Code: 1644. Rule 6 Violation: Material is not registered in site inventory.
INSERT INTO MATERIAL_USAGE (TaskID, MaterialID, SiteID, UsageDate, UsedQuantity)
VALUES ('TSK103', 'MAT002', 'SITE01', '2024-11-15', 5.00);

-- [6.4 - TEST HOP LE: TU DONG TRU KHO KHI XUAT VAT TU]
-- Kiem tra truoc -> Insert xuat 10.00 tan -> Kiem tra sau (145.00 giam con 135.00) -> Cleanup.
SELECT CurrentStockQuantity AS StockBeforeUsage
FROM SITE_INVENTORY WHERE SiteID = 'SITE01' AND MaterialID = 'MAT001';

INSERT INTO MATERIAL_USAGE (TaskID, MaterialID, SiteID, UsageDate, UsedQuantity)
VALUES ('TSK103', 'MAT001', 'SITE01', '2024-11-15', 10.00);

SELECT CurrentStockQuantity AS StockAfterUsage
FROM SITE_INVENTORY WHERE SiteID = 'SITE01' AND MaterialID = 'MAT001';

-- [CLEANUP 6.4] Khoi phuc lai du lieu mau
DELETE FROM MATERIAL_USAGE
WHERE TaskID = 'TSK103' AND MaterialID = 'MAT001' AND SiteID = 'SITE01' AND UsageDate = '2024-11-15';
UPDATE SITE_INVENTORY
SET CurrentStockQuantity = CurrentStockQuantity + 10.00
WHERE SiteID = 'SITE01' AND MaterialID = 'MAT001';

-- [6.5 - TEST HOP LE: TU DONG CONG KHO KHI NHAP HANG (Status = 'Received')]
-- Kiem tra truoc -> Insert phieu giao 50.00 tan -> Kiem tra sau (tang them 50.00) -> Cleanup.
SELECT CurrentStockQuantity AS StockBeforeDelivery
FROM SITE_INVENTORY WHERE SiteID = 'SITE01' AND MaterialID = 'MAT001';

INSERT INTO DELIVERY_DISPATCH (DeliveryCode, DeliveryDate, DeliveredQuantity, Status, MaterialID, SiteID, ReceivedByEmpID, PO_ID)
VALUES ('DEL-TEST-001', '2024-11-16', 50.00, 'Received', 'MAT001', 'SITE01', 'EMP013', 'PO2024-001');

SELECT CurrentStockQuantity AS StockAfterDelivery
FROM SITE_INVENTORY WHERE SiteID = 'SITE01' AND MaterialID = 'MAT001';

-- [CLEANUP 6.5] Khoi phuc lai du lieu mau
DELETE FROM DELIVERY_DISPATCH WHERE DeliveryCode = 'DEL-TEST-001';
UPDATE SITE_INVENTORY
SET CurrentStockQuantity = CurrentStockQuantity - 50.00
WHERE SiteID = 'SITE01' AND MaterialID = 'MAT001';


-- =============================================================================
-- RULE 7: Single Active Project Limit for Site Directors
-- Quy tac: Moi Giam doc cong truong chi duoc quan ly toi da 1 du an 'Active'.
-- Triggers: TRG_CHECK_DIRECTOR_ACTIVE_PROJECT_INSERT,
--           TRG_CHECK_DIRECTOR_ACTIVE_PROJECT_UPDATE
-- =============================================================================

-- [7.1 - AUDIT] Kiem tra so luong du an Active cua tung Director
SELECT 
    p.DirectorEmpID,
    CONCAT(e.FirstName, ' ', e.LastName) AS DirectorName,
    SUM(CASE WHEN p.Status = 'Active' THEN 1 ELSE 0 END) AS ActiveProjectCount,
    COUNT(*) AS TotalProjectsAssigned,
    GROUP_CONCAT(CONCAT(p.ProjectID, ' (', p.Status, ')') SEPARATOR ', ') AS ProjectList,
    CASE 
        WHEN SUM(CASE WHEN p.Status = 'Active' THEN 1 ELSE 0 END) <= 1 THEN 'PASS'
        ELSE 'VIOLATION'
    END AS Rule7_Status
FROM PROJECT p
JOIN EMPLOYEE e ON p.DirectorEmpID = e.EmpID
GROUP BY p.DirectorEmpID, e.FirstName, e.LastName;

-- [7.2 - TEST VI PHAM INSERT] (Theo proof r7 trong bao cao)
-- EMP003 hien dang quan ly PRJ001 co Status = 'Active'.
-- Them PRJ999 voi Status = 'Active' va DirectorEmpID = 'EMP003'.
-- Ky vong: Error Code: 1644. Rule 7 Violation: Site director is already managing an active project.
INSERT INTO PROJECT (
    ProjectID, ProjectName, ContractNumber, EstimatedBudget, ActualCost,
    StartDate, ScheduledEndDate, ActualEndDate, Status, ClientID, DeptID, DirectorEmpID
)
VALUES (
    'PRJ999', 'Test Duplicate Active Project', 'HD-TEST-999', 50000000000.00, 0.00,
    '2025-01-01', '2026-01-01', NULL, 'Active', 'CLI01', 'DEP03', 'EMP003'
);

-- [7.3 - TEST VI PHAM UPDATE]
-- Chuyen PRJ003 (dang o trang thai 'Planning') sang cho EMP003 va doi Status = 'Active'.
-- Ky vong: Error Code: 1644. Rule 7 Violation: Site director is already managing an active project.
UPDATE PROJECT
SET DirectorEmpID = 'EMP003', Status = 'Active'
WHERE ProjectID = 'PRJ003';


-- =============================================================================
-- RULE 8: Automated Emergency Contact Notification on Incident
-- Quy tac: Khi ghi nhan su co Level-2, Level-3 hoac Level-4 co InvolvedEmpID,
--          he thong tu dong tim nguoi than (IsEmergencyContact = TRUE) va ghi
--          nhat ky gui canh bao vao bang EMERGENCY_DISPATCH_LOG.
-- Trigger: TRG_DISPATCH_EMERGENCY_ALERT (AFTER INSERT ON INCIDENT_REPORT)
-- =============================================================================

-- [8.1 - AUDIT / Verification Query 3.1 trong bao cao]
-- Kiem chung su co INC-2024-02 (Level-2, EMP010) da tu dong sinh log,
-- trong khi INC-2024-01 (Level-1, NULL) khong sinh log.
SELECT 
    l.LogID,
    l.IncidentID,
    l.InvolvedEmpID,
    CONCAT(e.FirstName, ' ', e.LastName) AS InjuredEmployee,
    l.EmergencyContactName,
    l.Relationship,
    l.ContactPhone,
    l.DispatchedAt,
    l.MessageSubject,
    l.MessageBody,
    l.NotificationStatus
FROM EMERGENCY_DISPATCH_LOG l
JOIN EMPLOYEE e ON l.InvolvedEmpID = e.EmpID
ORDER BY l.LogID DESC;

-- [8.2 - TEST KICH HOAT MOI (Level-3 Incident)] (Theo proof r8 trong bao cao)
-- Them su co INC-2024-99 muc Level-3 lien quan den EMP010 (co nguoi lien he khan cap: Thi Tuyet Mai).
INSERT INTO INCIDENT_REPORT (
    IncidentID, IncidentTimestamp, IncidentType, IncidentLevel,
    DamageDescription, LostDays, Solution, SiteID, InvolvedEmpID, DamagedEquipmentID
)
VALUES (
    'INC-2024-99', '2024-11-14 09:00:00', 'Equipment-Damage', 'Level-3',
    'Test Level-3 incident for Rule 8 emergency dispatch verification',
    5, 'Halted tower crane operation, provided medical care and safety audit',
    'SITE01', 'EMP010', 'EQP001'
);

-- Kiem tra EMERGENCY_DISPATCH_LOG da tu dong them ban ghi cho INC-2024-99
SELECT 
    l.LogID,
    l.IncidentID,
    l.InvolvedEmpID,
    CONCAT(e.FirstName, ' ', e.LastName) AS InjuredEmployee,
    l.EmergencyContactName,
    l.Relationship,
    l.ContactPhone,
    l.DispatchedAt,
    l.MessageSubject,
    l.MessageBody,
    l.NotificationStatus
FROM EMERGENCY_DISPATCH_LOG l
JOIN EMPLOYEE e ON l.InvolvedEmpID = e.EmpID
WHERE l.IncidentID IN ('INC-2024-02', 'INC-2024-99')
ORDER BY l.LogID DESC;

-- [CLEANUP 8.2] Xoa su co test (FK_DISPATCH_Incident co ON DELETE CASCADE se tu dong xoa log test)
DELETE FROM INCIDENT_REPORT WHERE IncidentID = 'INC-2024-99';
