**HỌC VIỆN CÔNG NGHỆ BƯU CHÍNH VIỄN THÔNG**

**KHOA CÔNG NGHỆ THÔNG TIN**

![](./logo.png)

**DATABASE DESIGN TERM PROJECT**

Database system for a construction company with multiple projects

Course: Database [E24-Class 5]  
Team: 5  
Members:
- Lê Anh Minh - B24DCCE180
- Ứng Trọng Trình - B24DCCE271
- Nguyễn Đinh Anh Quân - B24DCCE222

Instructor: Nguyễn Đình Hoá

# 1. Company background and scenario

## 1.1 Overview

A34Build is a general contractor handling civil infrastructure, commercial buildings, and industrial facilities. The company runs multiple active projects simultaneously across distributed job sites, each governed by contractual deadlines, fixed budgets, and statutory safety requirements. Daily operations coordinate field engineers, site managers, equipment operators, heavy machinery, specialized subcontractors, and bulk construction materials.

Because operations currently rely on spreadsheets and paper logs, project teams experience scheduling delays, budget overruns, on-site inventory loss, and delayed cost tracking. The target relational database centralizes project schedules, workforce assignments, equipment utilization, material procurement, subcontracting, and site safety compliance.

## 1.2 Main business operations

Database coverage spans seven operational areas:

1. Projects: Client contracts, job sites, project phases, and scheduled work packages.
2. Workforce: Job roles, reporting hierarchy, certifications, dependents, and task assignments.
3. Equipment: Owned and rented machinery, site deployments, operating hours, and maintenance logs.
4. Materials: Suppliers, purchase orders, site deliveries, stock levels, and task consumption.
5. Subcontractors: Trade specialties, subcontract agreements, warranty holdbacks, and safety ratings.
6. Project costs: Budget variance tracking across labor, equipment, materials, and subcontracts.
7. Safety: Site safety audits, inspection scores, and workplace incident reports.

# 2. Data requirements

## 2.1 Entity sets

### Strong entity sets

1. DEPARTMENT: Company organizational units (Civil Engineering, Heavy Fleet, Procurement, Safety, Finance).
2. EMPLOYEE: Full-time and field staff (engineers, managers, operators, inspectors).
3. CLIENT: Public agencies and private developers commissioning projects.
4. PROJECT: Construction contracts with defined budgets and delivery schedules.
5. PROJECT_SITE: Physical work locations belonging to a project.
6. TASK: Work packages within a project phase assigned to workers.
7. EQUIPMENT: Heavy machinery and construction vehicles.
8. SUPPLIER: Vendors supplying raw materials and parts.
9. MATERIAL: Standard catalog items (cement, rebar, gravel, pipes).
10. PURCHASE_ORDER: Procurement orders issued to suppliers.
11. SUBCONTRACTOR: External contractors hired for specialized trades.
12. SAFETY_INSPECTION: Periodic site safety audits.
13. INCIDENT_REPORT: Logs of workplace accidents, equipment damage, or near-misses.

### Weak entity sets

1. DEPENDENT: Family members of an employee recorded for benefits and emergency contact (identifying entity: `EMPLOYEE`; identifying relationship: `HAS_DEPENDENT`; partial key: `DependentName`).
2. PROJECT_PHASE: Sequential stages within a project such as Foundation, Structure, and Finishing (identifying entity: `PROJECT`; identifying relationship: `CONSISTS_OF_PHASES`; partial key: `PhaseNumber`).
3. PO_ITEM: Individual line items on a purchase order (identifying entity: `PURCHASE_ORDER`; identifying relationship: `CONTAINS_ITEM`; partial key: `LineNumber`).
4. MAINTENANCE_RECORD: Service and repair logs for a machine (identifying entity: `EQUIPMENT`; identifying relationship: `HAS_MAINTENANCE`; partial key: `RecordNumber`).

## 2.2 Attributes

### Strong entity sets

#### 1. DEPARTMENT

| Attribute      | Type        | Description                        |
|----------------|-------------|------------------------------------|
| DeptID         | Primary Key | Unique department code (e.g., D01) |
| DeptName       | Simple      | Department name                    |
| OfficeLocation | Simple      | Office room or floor               |
| Budget         | Simple      | Annual operating budget            |

#### 2. EMPLOYEE

| Attribute | Type | Description |
|----|----|----|
| EmpID | Primary Key | Unique employee identifier |
| Name | Composite | Composed of FirstName, MiddleName, LastName |
| Address | Composite | Composed of Street, Ward, District, City |
| DOB | Simple | Date of birth |
| Age | Derived | Current date minus date of birth |
| HireDate | Simple | Employment start date |
| Salary | Simple | Monthly base salary |
| JobTitle | Simple | Job title (Site Engineer, Crane Operator) |
| Email | Candidate Key | Unique company email |
| PhoneNumber | Multi-valued | Contact phone numbers |
| Certifications | Multi-valued | Licenses and certificates (OSHA, Crane Class A) |

#### 3. CLIENT

| Attribute | Type | Description |
|----|----|----|
| ClientID | Primary Key | Unique client identifier |
| ClientName | Simple | Organization or company name |
| TaxCode | Candidate Key | Business tax code |
| RepresentativeName | Simple | Primary authorized representative |
| Email | Candidate Key | Official contact email address |
| Address | Composite | Composed of Street, Ward, District, City |
| ContactPhone | Multi-valued | Contact phone numbers |

#### 4. PROJECT

| Attribute | Type | Description |
|----|----|----|
| ProjectID | Primary Key | Project code (e.g., PRJ001) |
| ProjectName | Candidate Key | Unique project name |
| ContractNumber | Candidate Key | Unique signed contract reference |
| EstimatedBudget | Simple | Contract budget limit |
| ActualCost | Derived | Total cost of labor, equipment, materials, and subcontracts |
| StartDate | Simple | Planned start date |
| ScheduledEndDate | Simple | Contractual scheduled deadline |
| ActualEndDate | Simple | Real completion date (null if ongoing) |
| ProjectDuration | Derived | Elapsed days from StartDate to ActualEndDate or today |
| Status | Simple | Planning, Active, Suspended, Completed, Cancelled |

#### 5. PROJECT_SITE

| Attribute | Type | Description |
|----|----|----|
| SiteID | Primary Key | Unique site identifier |
| SiteName | Simple | Site name or sector |
| Address | Composite | Composed of Street, Ward, District, City |
| LocationCoordinates | Composite | Composed of Latitude, Longitude |

#### 6. TASK

| Attribute | Type | Description |
|----|----|----|
| TaskID | Primary Key | Unique task identifier |
| TaskName | Simple | Task name |
| Description | Simple | Detailed scope and technical notes |
| EstimatedCost | Simple | Estimated task cost |
| ActualCost | Derived | Actual accumulated task cost |
| StartDate | Simple | Scheduled start date |
| EndDate | Simple | Scheduled end date |
| Status | Simple | Execution state (Not-Started, In-Progress, Completed, Blocked) |

#### 7. EQUIPMENT

| Attribute | Type | Description |
|----|----|----|
| EquipmentID | Primary Key | Unique asset code |
| SerialNumber | Candidate Key | Manufacturer serial number |
| EquipmentName | Simple | Make and equipment name |
| Category | Simple | Equipment category (Tower Crane, Heavy Crane, Excavator, Concrete Pump, Asphalt Roller) |
| Capacity | Simple | Rated operating capacity (e.g., 12 Tons, 2.5 m3) |
| HourlyRate | Simple | Cost per operating hour |
| Status | Simple | Available, Deployed, Under-Maintenance, Decommissioned |
| TotalRunHours | Derived | Total operating hours across all jobs |

#### 8. SUPPLIER

| Attribute | Type | Description |
|----|----|----|
| SupplierID | Primary Key | Unique vendor identifier |
| SupplierName | Simple | Registered company name |
| TaxCode | Candidate Key | Official business tax ID |
| Email | Candidate Key | Official sales email |
| Address | Composite | Composed of Street, Ward, District, City |
| ContactPhone | Multi-valued | Contact phone numbers |
| SupplyCategories | Multi-valued | Product lines (Reinforcing Steel, Cement, Concrete) |

#### 9. MATERIAL

| Attribute | Type | Description |
|----|----|----|
| MaterialID | Primary Key | Unique material SKU |
| MaterialName | Candidate Key | Material name (e.g., Portland Blended Cement PCB40 Bulk) |
| Unit | Simple | Unit of measurement (Ton, m3, Bag, Piece) |
| StandardPrice | Simple | Benchmark price per unit |

#### 10. PURCHASE_ORDER

| Attribute | Type | Description |
|----|----|----|
| PO_ID | Primary Key | Unique PO number |
| OrderDate | Simple | Date order was placed |
| TotalAmount | Derived | Sum of line subtotals |
| Status | Simple | Draft, Approved, Shipped, Received, Cancelled |

#### 11. SUBCONTRACTOR

| Attribute | Type | Description |
|----|----|----|
| SubcontractorID | Primary Key | Unique subcontractor identifier |
| SubcontractorName | Simple | Registered company name |
| TaxCode | Candidate Key | Official business tax ID |
| Specialization | Simple | Specialized trade (MEP, Diaphragm Wall, Post-Tensioning) |
| ContactPerson | Simple | Primary contact representative |
| ContactPhone | Simple | Primary dispatch phone number |
| ContactEmail | Simple | Official contact email |
| LicenseNumber | Candidate Key | Trade license number |

#### 12. SAFETY_INSPECTION

| Attribute | Type | Description |
|----|----|----|
| InspectionID | Primary Key | Unique inspection log ID |
| InspectionDate | Simple | Date of inspection |
| InspectionType | Simple | Audit type (Daily, Weekly, Monthly, Surprise, Post-Incident) |
| InspectionScope | Simple | Inspected area or structure |
| OverallScore | Simple | Evaluation score (0.00 to 100.00) |
| InspectionResult | Simple | Audit conclusion (Pass, Conditional-Pass, Fail) |
| ViolationNoted | Simple | Safety issues found |
| FixDeadline | Simple | Deadline to fix issues (null if passed) |

#### 13. INCIDENT_REPORT

| Attribute | Type | Description |
|----|----|----|
| IncidentID | Primary Key | Unique incident case ID |
| IncidentTimestamp | Simple | Date and time of incident |
| IncidentType | Simple | Event category (Near-Miss, Minor-Injury, Major-Injury, Fatality, Equipment-Damage, Fire, Collapse) |
| IncidentLevel | Simple | Impact classification (Level-1, Level-2, Level-3, Level-4) |
| DamageDescription | Simple | Injury or equipment damage details |
| LostDays | Simple | Work days lost due to injury |
| Solution | Simple | Immediate remedial or preventive action taken |

### Weak entity sets

#### 1. DEPENDENT

| Attribute | Type | Description |
|----|----|----|
| DependentName | Partial Key | Full name of dependent |
| Relationship | Simple | Relationship to employee (Spouse, Child, Parent) |
| Gender | Simple | Gender (Male, Female, Other) |
| DOB | Simple | Date of birth |
| IsEmergencyContact | Simple | Primary emergency contact flag (true or false) |

#### 2. PROJECT_PHASE

| Attribute | Type | Description |
|----|----|----|
| PhaseNumber | Partial Key | Phase sequence number (1, 2, 3...) |
| PhaseName | Simple | Phase title (Excavation, Structure) |
| PhaseBudget | Simple | Budget allocated to this phase |
| StartDate | Simple | Scheduled start date for this phase |
| ScheduledEndDate | Simple | Target completion date for phase |
| ActualEndDate | Simple | Real completion date (null if ongoing) |
| Status | Simple | Pending, In-Progress, Completed, Delayed |
| ProgressPercentage | Simple | Completion progress percentage (0.00 to 100.00) |

#### 3. PO_ITEM

| Attribute | Type | Description |
|----|----|----|
| LineNumber | Partial Key | Line item number (1, 2, 3...) |
| OrderQuantity | Simple | Quantity purchased |
| UnitPrice | Simple | Negotiated unit price |
| ItemSubtotal | Derived | OrderQuantity multiplied by UnitPrice |

#### 4. MAINTENANCE_RECORD

| Attribute | Type | Description |
|----|----|----|
| RecordNumber | Partial Key | Service record counter |
| MaintenanceDate | Simple | Date of service |
| MaintenanceType | Simple | Service type (Routine, Preventive, Corrective, Emergency) |
| Description | Simple | Scope of maintenance work |
| Cost | Simple | Repair and parts cost |
| PerformedBy | Simple | Workshop name or technical vendor |

# 3. Relationships and constraints

## 3.1 Relationships

### 1. DEPARTMENT_HEAD (EMPLOYEE to DEPARTMENT)

- Binary 1:1
- Participation: `DEPARTMENT` is total (every department has one manager); `EMPLOYEE` is partial (only some employees are department heads).
- Rule: An employee manages at most one department.

### 2. WORKS_IN_DEPARTMENT (DEPARTMENT to EMPLOYEE)

- Binary 1:N
- Participation: `EMPLOYEE` is total (every employee belongs to one department); `DEPARTMENT` is total (every department employs at least one person).
- Rule: An employee belongs to exactly one department.

### 3. SUPERVISES (EMPLOYEE to EMPLOYEE)

- Unary (recursive) 1:N
- Participation: Both roles are partial (not every employee supervises subordinates, and the top executive has no supervisor).
- Rule: An employee reports to at most one direct supervisor.

### 4. HAS_DEPENDENT (EMPLOYEE to DEPENDENT)

- Identifying 1:N
- Participation: `EMPLOYEE` is partial; `DEPENDENT` is total (each dependent belongs to one employee).

### 5. COMMISSIONS (CLIENT to PROJECT)

- Binary 1:N
- Participation: `CLIENT` is partial; `PROJECT` is total (every project is commissioned by a client).

### 6. DEPARTMENT_SPONSORS_PROJECT (DEPARTMENT to PROJECT)

- Binary 1:N
- Participation: `DEPARTMENT` is partial; `PROJECT` is total (each project is assigned to one managing department).

### 7. DIRECTS_PROJECT (EMPLOYEE to PROJECT)

- Binary 1:1
- Participation: `PROJECT` is total (every project has one site director); `EMPLOYEE` is partial.
- Rule: An employee directs at most one active project at a time.

### 8. HAS_SITES (PROJECT to PROJECT_SITE)

- Binary 1:N
- Participation: `PROJECT` is total (every project has at least one job site); `PROJECT_SITE` is total.

### 9. CONSISTS_OF_PHASES (PROJECT to PROJECT_PHASE)

- Identifying 1:N
- Participation: `PROJECT` is total; `PROJECT_PHASE` is total.

### 10. CONTAINS_TASKS (PROJECT_PHASE to TASK)

- Binary 1:N
- Participation: `PROJECT_PHASE` is total; `TASK` is total.

### 11. PRECEDES (TASK to TASK)

- Unary (recursive) M:N
- Participation: Both roles are partial.
- Rule: Defines scheduling dependencies among tasks (for example, foundation pouring finishes before structural framing begins).

### 12. WORKS_ON_TASK (EMPLOYEE to TASK)

- Binary M:N
- Attributes: `AssignedDate`, `RoleDescription`, `HoursLogged`
- Participation: `EMPLOYEE` is partial; `TASK` is total (every task requires at least one assigned worker).

### 13. EQUIPMENT_DEPLOYMENT (EQUIPMENT to PROJECT_SITE)

- Binary M:N (modeled as an aggregation for operator assignment)
- Attributes: `DeploymentStartDate`, `DeploymentEndDate`, `OperatingHours`
- Participation: Both `EQUIPMENT` and `PROJECT_SITE` are partial.

### 14. OPERATES (EMPLOYEE to EQUIPMENT_DEPLOYMENT)

- Binary 1:N over the `EQUIPMENT_DEPLOYMENT` aggregation
- Participation: `EMPLOYEE` is partial; `EQUIPMENT_DEPLOYMENT` is total (every equipment deployment must be assigned one certified primary operator).
- Rule: Associates each equipment deployment with exactly one primary operator (`OperatorEmpID` in the relational schema).

### 15. HAS_MAINTENANCE (EQUIPMENT to MAINTENANCE_RECORD)

- Identifying 1:N
- Participation: `EQUIPMENT` is partial; `MAINTENANCE_RECORD` is total.

### 16. ISSUES_PO (PROJECT to PURCHASE_ORDER)

- Binary 1:N
- Participation: `PROJECT` is partial; `PURCHASE_ORDER` is total.

### 17. SUPPLIES_PO (SUPPLIER to PURCHASE_ORDER)

- Binary 1:N
- Participation: `SUPPLIER` is partial; `PURCHASE_ORDER` is total.

### 18. CONTAINS_ITEM (PURCHASE_ORDER to PO_ITEM)

- Identifying 1:N
- Participation: `PURCHASE_ORDER` is total; `PO_ITEM` is total.

### 19. ITEM_REFERENCES_MATERIAL (PO_ITEM to MATERIAL)

- Binary N:1
- Participation: `PO_ITEM` is total; `MATERIAL` is partial.

### 20. SITE_INVENTORY (PROJECT_SITE to MATERIAL)

- Binary M:N
- Attributes: `CurrentStockQuantity`, `MinStock`, `ReorderQuantity`
- Participation: Both `PROJECT_SITE` and `MATERIAL` are partial.

### 21. DELIVERY_DISPATCH (SUPPLIER x MATERIAL x PROJECT_SITE)

- Ternary M:N:P (modeled as an aggregation for purchase-order fulfillment and receiving verification)
- Attributes: `DeliveryCode`, `DeliveryDate`, `DeliveredQuantity`, `Status`
- Participation: `SUPPLIER`, `MATERIAL`, and `PROJECT_SITE` are all partial.
- Rule: Captures each shipment of a specific material delivered by a supplier to a project site on a given date.

### 22. FULFILLS_PO (PURCHASE_ORDER to DELIVERY_DISPATCH)

- Binary 1:N over the `DELIVERY_DISPATCH` aggregation
- Participation: `PURCHASE_ORDER` is partial; `DELIVERY_DISPATCH` is total (every delivery fulfills an approved purchase order).

### 23. RECEIVES_DELIVERY (EMPLOYEE to DELIVERY_DISPATCH)

- Binary 1:N over the `DELIVERY_DISPATCH` aggregation
- Participation: `EMPLOYEE` is partial; `DELIVERY_DISPATCH` is total (every delivery is signed off by a receiving employee).

### 24. MATERIAL_USAGE (TASK x MATERIAL x PROJECT_SITE)

- Ternary N:M:P
- Attributes: `UsageDate`, `UsedQuantity`
- Participation: `TASK`, `MATERIAL`, and `PROJECT_SITE` are all partial.
- Rule: Records the quantity of a material consumed from a specific site inventory by a task on a given date.

### 25. ENGAGES_SUBCONTRACTOR (PROJECT to SUBCONTRACTOR)

- Binary M:N
- Attributes: `ContractAgreementNo`, `ScopeOfWork`, `ContractValue`, `WarrantyHoldRate`, `StartDate`, `EndDate`
- Participation: Both `PROJECT` and `SUBCONTRACTOR` are partial.

### 26. HAS_INSPECTION (PROJECT_SITE to SAFETY_INSPECTION)

- Binary 1:N
- Participation: `PROJECT_SITE` is partial; `SAFETY_INSPECTION` is total (every safety audit targets one site).

### 27. PERFORMS_INSPECTION (EMPLOYEE to SAFETY_INSPECTION)

- Binary 1:N
- Participation: `EMPLOYEE` is partial; `SAFETY_INSPECTION` is total (every safety audit is conducted by one assigned inspector).

### 28. LOGS_INCIDENT (PROJECT_SITE to INCIDENT_REPORT)

- Binary 1:N
- Participation: `PROJECT_SITE` is partial; `INCIDENT_REPORT` is total (every incident occurs at a project site).

### 29. INVOLVES_EMPLOYEE (EMPLOYEE to INCIDENT_REPORT)

- Binary 1:N
- Participation: Both `EMPLOYEE` and `INCIDENT_REPORT` are partial (an incident may involve an injured worker or only physical property/equipment).
- Rule: An incident report references at most one primary affected employee.

### 30. DAMAGES_EQUIPMENT (EQUIPMENT to INCIDENT_REPORT)

- Binary 1:N
- Participation: Both `EQUIPMENT` and `INCIDENT_REPORT` are partial (an incident may or may not damage a piece of machinery).

# 4. Business rules

## 4.1 Domain constraints

Numeric attributes enforce strict positivity or non-negativity bounds across financial, inventory, and scheduling records:

| Rule | Constraint | Applicable Attributes |
| :--- | :--- | :--- |
| Positive salaries and transaction quantities | > 0 | `Salary`, `PhaseNumber`, `LineNumber`, `RecordNumber`, `OrderQuantity`, `DeliveredQuantity`, `UsedQuantity` |
| Non-negative budgets, costs, stock, and hours | >= 0 | `Budget`, `EstimatedBudget`, `ActualCost`, `PhaseBudget`, `EstimatedCost`, `ContractValue`, `Cost`, `HourlyRate`, `StandardPrice`, `UnitPrice`, `TotalAmount`, `CurrentStockQuantity`, `MinStock`, `ReorderQuantity`, `OperatingHours`, `TotalRunHours`, `LostDays` |
| Bounded hours and percentages | Range check | `HoursLogged` (0.00 to 24.00 per row, max 12.00 daily total), `ProgressPercentage` (0.00 to 100.00), `WarrantyHoldRate` (0.00 to 100.00), `OverallScore` (0.00 to 100.00) |

Categorical and status attributes accept fixed enumerated values:

| Entity.Attribute | Allowed Values |
| :--- | :--- |
| `DEPENDENT.Gender` | `Male`, `Female`, `Other` |
| `PROJECT.Status` | `Planning`, `Active`, `Suspended`, `Completed`, `Cancelled` |
| `PROJECT_PHASE.Status` | `Pending`, `In-Progress`, `Completed`, `Delayed` |
| `TASK.Status` | `Not-Started`, `In-Progress`, `Completed`, `Blocked` |
| `EQUIPMENT.Status` | `Available`, `Deployed`, `Under-Maintenance`, `Decommissioned` |
| `MAINTENANCE_RECORD.MaintenanceType` | `Routine`, `Preventive`, `Corrective`, `Emergency` |
| `PURCHASE_ORDER.Status` | `Draft`, `Approved`, `Shipped`, `Received`, `Cancelled` |
| `DELIVERY_DISPATCH.Status` | `In-Transit`, `Received`, `Rejected` |
| `SAFETY_INSPECTION.InspectionType` | `Daily`, `Weekly`, `Monthly`, `Surprise`, `Post-Incident` |
| `SAFETY_INSPECTION.InspectionResult` | `Pass`, `Conditional-Pass`, `Fail` |
| `INCIDENT_REPORT.IncidentType` | `Near-Miss`, `Minor-Injury`, `Major-Injury`, `Fatality`, `Equipment-Damage`, `Fire`, `Collapse` |
| `INCIDENT_REPORT.IncidentLevel` | `Level-1`, `Level-2`, `Level-3`, `Level-4` |

## 4.2 Date and time rules

- Chronological endpoints must not precede start dates across all scheduled records: `PROJECT` (`StartDate <= ScheduledEndDate`, `StartDate <= ActualEndDate`), `PROJECT_PHASE` (`StartDate <= ScheduledEndDate`, `StartDate <= ActualEndDate`), `TASK` (`StartDate <= EndDate`), `EQUIPMENT_DEPLOYMENT` (`DeploymentStartDate <= DeploymentEndDate`), `ENGAGES_SUBCONTRACTOR` (`StartDate <= EndDate`), and `SAFETY_INSPECTION` (`InspectionDate <= FixDeadline` when `FixDeadline` is non-null).
- Workers must be at least 18 years old at hiring and at runtime (`CurrentDate - DOB >= 18 years` and `HireDate >= DOB + 18 years`).
- Task `StartDate` and `EndDate` values must fall within the parent `PROJECT_PHASE` interval (`StartDate` to `ScheduledEndDate`).

## 4.3 Rules not modeled in ERD

These cross-entity and dynamic constraints cannot be expressed directly in Chen EER notation and require triggers, check constraints, or application logic:

1. Phase budget limit: The sum of `PhaseBudget` across all phases of a project cannot exceed `PROJECT.EstimatedBudget`.
2. No overlapping machine bookings: An `EQUIPMENT` unit cannot have overlapping `[DeploymentStartDate, DeploymentEndDate]` intervals across different sites in `EQUIPMENT_DEPLOYMENT`.
3. Operator licensing: An employee linked via `OPERATES` to `EQUIPMENT_DEPLOYMENT` must hold a matching equipment license in `EMPLOYEE.Certifications`.
4. Daily work limit: Total `HoursLogged` across all `WORKS_ON_TASK` records for a single employee on the same `AssignedDate` cannot exceed 12 hours.
5. No circular task dependencies: The recursive `PRECEDES` graph over `TASK` must remain a directed acyclic graph (DAG) with no self-loops or cycles.
6. Stock limit on consumption: `MATERIAL_USAGE.UsedQuantity` for a given `(MaterialID, SiteID)` cannot exceed `SITE_INVENTORY.CurrentStockQuantity` at that site.
7. Single active project limit for directors: Although `DIRECTS_PROJECT` is modeled as 1:1 in the conceptual schema, historical project records require enforcing that an employee directs at most one `Active` project at any given time.

# 5. Database applications

## 5.1 Data loading

- Import the standard `MATERIAL` catalog with `Unit` and benchmark `StandardPrice`.
- Register `EMPLOYEE` records with `JobTitle`, assigned `DEPARTMENT`, and verified `Certifications`.
- Initialize `PROJECT` contracts, `PROJECT_SITE` coordinates, and `PROJECT_PHASE` milestone schedules.
- Register heavy `EQUIPMENT` assets with unique `SerialNumber`, `Category`, `Capacity`, and `HourlyRate` values.

## 5.2 Updates

- Log worker `HoursLogged` and `RoleDescription` on assigned `TASK` records.
- Record `DELIVERY_DISPATCH` arrivals against `PURCHASE_ORDER` items and increment `SITE_INVENTORY.CurrentStockQuantity`.
- Record `MATERIAL_USAGE` quantities during task execution and deduct from on-site `CurrentStockQuantity`.
- Accumulate `EQUIPMENT_DEPLOYMENT.OperatingHours`, update `TotalRunHours`, and transition `EQUIPMENT.Status` to `Under-Maintenance` when service intervals arrive.
- Transition `PROJECT_PHASE.Status` to `Completed` and update `ProgressPercentage` after milestone sign-off.
- Record `SAFETY_INSPECTION` scores, remediation deadlines, and `INCIDENT_REPORT` cases.

## 5.3 Queries

- Retrieve `Available` equipment by `Category` with no scheduled `EQUIPMENT_DEPLOYMENT` overlap in the next two weeks.
- Identify `SITE_INVENTORY` items at a site where `CurrentStockQuantity` has fallen below `MinStock` or `ReorderQuantity`.
- List tasks whose `Status` is not `Completed` past `EndDate`.
- Traverse the recursive `SUPERVISES` chain from any `EMPLOYEE` up to the general director.
- Retrieve active subcontractors on a project with `ContractValue` and retained `WarrantyHoldRate` amounts.

## 5.4 Reports

- Cost vs. budget variance: Compares `PROJECT.EstimatedBudget` against aggregated spending across labor, equipment deployments, material consumption, and subcontracts (`ActualCost`).
- Earned value analysis: Computes Planned Value (PV), Earned Value (EV), Actual Cost (AC), Cost Performance Index (CPI), and Schedule Performance Index (SPI).
- Site safety report: Summarizes `SAFETY_INSPECTION.OverallScore`, unresolved violations, `INCIDENT_REPORT.LostDays`, and injury-free hours per site.
- Subcontractor scorecard: Ranks subcontractors by schedule adherence, contract scope delivery, and site inspection outcomes.
- Fleet utilization report: Compares `TotalRunHours` and `OperatingHours` against maintenance cost and `HourlyRate` revenue generation.

# 6. Entity-Relationship Diagram

## 6.1 Diagram overview and notation

![Entity-Relationship Diagram of the A34Build database](./erd/erd.png "ERD of the A34Build construction company database, color-coded by domain")

*Figure 1: Entity-Relationship Diagram of the A34Build database, covering 17 entity sets (13 strong, 4 weak) and 30 relationships color-coded across six operational domains.*

In Chen EER notation, rectangles denote strong entity sets, double rectangles denote weak entity sets, diamonds denote regular relationships, and double diamonds denote identifying relationships. Ellipses represent attributes: underlined for primary keys, dashed-underlined for partial keys, double-lined for multi-valued attributes, and dashed-outlined for derived attributes. Double lines indicate total participation, while single lines indicate partial participation. Cardinalities are labeled `1`, `N`, `M`, and `P`. Dashed aggregation boxes enclose `EQUIPMENT_DEPLOYMENT` and `DELIVERY_DISPATCH` so those relationships participate directly in `OPERATES`, `FULFILLS_PO`, and `RECEIVES_DELIVERY`.

## 6.2 Conceptual model by domain

Each of the six color-coded ERD domains groups related entity sets, relationship cardinalities, participation rules, and attribute classifications:

1. Organization (blue)
   - Entity sets: Strong entities `DEPARTMENT` (key: `DeptID`) and `EMPLOYEE` (key: `EmpID`), plus weak entity `DEPENDENT` (identifying owner: `EMPLOYEE`; partial key: `DependentName`).
   - Relationships: `DEPARTMENT_HEAD` (1:1, total `DEPARTMENT`, partial `EMPLOYEE`), `WORKS_IN_DEPARTMENT` (1:N, total on both), `SUPERVISES` (recursive 1:N on `EMPLOYEE`, partial on both), and `HAS_DEPENDENT` (identifying 1:N, partial `EMPLOYEE`, total `DEPENDENT`).
   - Attribute classifications: `EMPLOYEE.Name` (`FirstName`, `MiddleName`, `LastName`) and `EMPLOYEE.Address` (`Street`, `Ward`, `District`, `City`) are composite; `Age` is derived; `Email` is a candidate key; `PhoneNumber` and `Certifications` are multi-valued.
2. Projects (green)
   - Entity sets: Strong entities `CLIENT` (key: `ClientID`), `PROJECT` (key: `ProjectID`), `PROJECT_SITE` (key: `SiteID`), and `TASK` (key: `TaskID`), plus weak entity `PROJECT_PHASE` (identifying owner: `PROJECT`; partial key: `PhaseNumber`).
   - Relationships: `COMMISSIONS` (1:N, partial `CLIENT`, total `PROJECT`), `DEPARTMENT_SPONSORS_PROJECT` (1:N, partial `DEPARTMENT`, total `PROJECT`), `DIRECTS_PROJECT` (1:1, partial `EMPLOYEE`, total `PROJECT`), `HAS_SITES` (1:N, total on both), `CONSISTS_OF_PHASES` (identifying 1:N, total on both), `CONTAINS_TASKS` (1:N, total on both), `PRECEDES` (recursive M:N on `TASK`, partial on both), and `WORKS_ON_TASK` (M:N, partial `EMPLOYEE`, total `TASK`, with `AssignedDate`, `RoleDescription`, `HoursLogged`).
   - Attribute classifications: `CLIENT.TaxCode` and `CLIENT.Email` are candidate keys, `CLIENT.Address` (`Street`, `Ward`, `District`, `City`) is composite, and `ContactPhone` is multi-valued; `PROJECT.ProjectName` and `PROJECT.ContractNumber` are candidate keys; `PROJECT_SITE` has composite `LocationCoordinates` (`Latitude`, `Longitude`) and composite `Address` (`Street`, `Ward`, `District`, `City`); `PROJECT.ProjectDuration`, `PROJECT.ActualCost`, and `TASK.ActualCost` are derived.
3. Equipment (orange)
   - Entity sets: Strong entity `EQUIPMENT` (key: `EquipmentID`) and weak entity `MAINTENANCE_RECORD` (identifying owner: `EQUIPMENT`; partial key: `RecordNumber`).
   - Relationships: `HAS_MAINTENANCE` (identifying 1:N, partial `EQUIPMENT`, total `MAINTENANCE_RECORD`), `EQUIPMENT_DEPLOYMENT` (M:N between `EQUIPMENT` and `PROJECT_SITE`, partial on both, with `DeploymentStartDate`, `DeploymentEndDate`, `OperatingHours`), and `OPERATES` (1:N between `EMPLOYEE` and the `EQUIPMENT_DEPLOYMENT` aggregation, partial `EMPLOYEE`, total `EQUIPMENT_DEPLOYMENT`).
   - Attribute classifications: `EQUIPMENT.SerialNumber` is a candidate key; `TotalRunHours` is derived; `EQUIPMENT_DEPLOYMENT` acts as an aggregation so operator assignment attaches directly via `OPERATES`.
4. Materials and procurement (purple)
   - Entity sets: Strong entities `SUPPLIER` (key: `SupplierID`), `PURCHASE_ORDER` (key: `PO_ID`), and `MATERIAL` (key: `MaterialID`), plus weak entity `PO_ITEM` (identifying owner: `PURCHASE_ORDER`; partial key: `LineNumber`).
   - Relationships: `ISSUES_PO` (`PROJECT` 1:N `PURCHASE_ORDER`, partial `PROJECT`, total `PURCHASE_ORDER`), `SUPPLIES_PO` (`SUPPLIER` 1:N `PURCHASE_ORDER`, partial `SUPPLIER`, total `PURCHASE_ORDER`), `CONTAINS_ITEM` (identifying 1:N, total on both), `ITEM_REFERENCES_MATERIAL` (`PO_ITEM` N:1 `MATERIAL`, total `PO_ITEM`, partial `MATERIAL`), `SITE_INVENTORY` (`PROJECT_SITE` M:N `MATERIAL`, partial on both, with `CurrentStockQuantity`, `MinStock`, `ReorderQuantity`), ternary `DELIVERY_DISPATCH` (`SUPPLIER` x `MATERIAL` x `PROJECT_SITE`, all partial, with `DeliveryCode`, `DeliveryDate`, `DeliveredQuantity`, `Status`), `FULFILLS_PO` (`PURCHASE_ORDER` 1:N over `DELIVERY_DISPATCH` aggregation, partial `PURCHASE_ORDER`, total `DELIVERY_DISPATCH`), `RECEIVES_DELIVERY` (`EMPLOYEE` 1:N over `DELIVERY_DISPATCH` aggregation, partial `EMPLOYEE`, total `DELIVERY_DISPATCH`), and ternary `MATERIAL_USAGE` (`TASK` x `MATERIAL` x `PROJECT_SITE`, all partial, with `UsageDate`, `UsedQuantity`).
   - Attribute classifications: `SUPPLIER.TaxCode` and `SUPPLIER.Email` are candidate keys, `SUPPLIER.Address` (`Street`, `Ward`, `District`, `City`) is composite, while `ContactPhone` and `SupplyCategories` are multi-valued; `MATERIAL.MaterialName` is a candidate key; `PO_ITEM.ItemSubtotal` and `PURCHASE_ORDER.TotalAmount` are derived; `DELIVERY_DISPATCH` is wrapped as an aggregation to attach purchase-order fulfillment and receiving verification.
5. Subcontractors (yellow)
   - Entity sets: Strong entity `SUBCONTRACTOR` (key: `SubcontractorID`), connected across domains to `PROJECT`.
   - Relationships: `ENGAGES_SUBCONTRACTOR` (M:N between `PROJECT` and `SUBCONTRACTOR`, partial on both, carrying `ContractAgreementNo`, `ScopeOfWork`, `ContractValue`, `WarrantyHoldRate`, `StartDate`, and `EndDate`).
   - Attribute classifications: `SUBCONTRACTOR.TaxCode` and `SUBCONTRACTOR.LicenseNumber` are candidate keys; `ContractAgreementNo` uniquely identifies each engagement contract across projects.
6. Safety (red)
   - Entity sets: Strong entities `SAFETY_INSPECTION` (key: `InspectionID`) and `INCIDENT_REPORT` (key: `IncidentID`).
   - Relationships: `HAS_INSPECTION` (`PROJECT_SITE` 1:N `SAFETY_INSPECTION`, partial `PROJECT_SITE`, total `SAFETY_INSPECTION`), `PERFORMS_INSPECTION` (`EMPLOYEE` 1:N `SAFETY_INSPECTION`, partial `EMPLOYEE`, total `SAFETY_INSPECTION`), `LOGS_INCIDENT` (`PROJECT_SITE` 1:N `INCIDENT_REPORT`, partial `PROJECT_SITE`, total `INCIDENT_REPORT`), `INVOLVES_EMPLOYEE` (`EMPLOYEE` 1:N `INCIDENT_REPORT`, partial on both), and `DAMAGES_EQUIPMENT` (`EQUIPMENT` 1:N `INCIDENT_REPORT`, partial on both).
   - Attribute and participation notes: `SAFETY_INSPECTION.FixDeadline` applies when violations are recorded; partial participation on `INVOLVES_EMPLOYEE` and `DAMAGES_EQUIPMENT` allows an `INCIDENT_REPORT` to document property-only or non-injury incidents.

# 7. Relational Schemas

## 7.1 Mapping rules and diagram

![Relational Schema of the A34Build database](./schema/schema.png "Relational schema of the A34Build construction company database, color-coded by domain")

*Figure 2: Relational schema of the A34Build database across 29 tables and 44 foreign-key references.*

Converting the Chen ERD yields 29 relation schemas under standard relational mapping rules: composite attributes (`Name`, `Address`, `LocationCoordinates`) expand into atomic scalar columns, multi-valued attributes (`ContactPhone`, `PhoneNumber`, `Certifications`, `SupplyCategories`) map to dedicated child tables keyed by owner key plus attribute value, and purely derived attributes (`Age`, `ProjectDuration`, `ItemSubtotal`) are excluded from stored columns, while materialized ledger totals (`PROJECT.ActualCost`, `TASK.ActualCost`, `EQUIPMENT.TotalRunHours`, `PURCHASE_ORDER.TotalAmount`) are retained as cached numeric columns for reporting. Weak entities inherit their identifying owner's primary key combined with their partial key, while 1:1, 1:N, M:N, ternary, and aggregation relationships map via foreign keys or associative tables. In Figure 2, underlined columns form the primary key, dashed-underlined columns mark weak-entity partial keys, and arrows point from each foreign key to its referenced primary key.

## 7.2 Schema definitions by domain

### 7.2.1 Organization

`EMPLOYEE.Name` and `EMPLOYEE.Address` decompose into atomic columns, `Age` is omitted as derived, and `PhoneNumber` and `Certifications` extract into separate tables. `DEPARTMENT.HeadEmpID` and `EMPLOYEE.DeptID` form a mutual foreign-key pair resolved during physical table creation.

| Table | Primary Key | Attributes | Foreign Keys |
| :--- | :--- | :--- | :--- |
| DEPARTMENT | `DeptID` | `DeptID`, `DeptName`, `OfficeLocation`, `Budget`, `HeadEmpID` | `HeadEmpID -> EMPLOYEE(EmpID)` |
| EMPLOYEE | `EmpID` | `EmpID`, `FirstName`, `MiddleName`, `LastName`, `Street`, `Ward`, `District`, `City`, `DOB`, `HireDate`, `Salary`, `JobTitle`, `Email`, `DeptID`, `SupervisorID` | `DeptID -> DEPARTMENT(DeptID)`; `SupervisorID -> EMPLOYEE(EmpID)` |
| EMPLOYEE_PHONE | `EmpID`, `PhoneNumber` | `EmpID`, `PhoneNumber` | `EmpID -> EMPLOYEE(EmpID)` |
| EMPLOYEE_CERTIFICATION | `EmpID`, `Certification` | `EmpID`, `Certification` | `EmpID -> EMPLOYEE(EmpID)` |
| DEPENDENT | `EmpID`, `DependentName` (partial key) | `EmpID`, `DependentName`, `Relationship`, `Gender`, `DOB`, `IsEmergencyContact` | `EmpID -> EMPLOYEE(EmpID)` |

### 7.2.2 Projects

`CLIENT.ContactPhone` extracts into `CLIENT_PHONE`, `CLIENT` and `PROJECT_SITE` expand composite `Address` and `LocationCoordinates` into atomic columns, `ProjectDuration` is omitted as derived while `PROJECT.ActualCost` and `TASK.ActualCost` are retained as materialized totals, and `TASK` references `PROJECT_PHASE` through the composite foreign key `(ProjectID, PhaseNumber)`.

| Table | Primary Key | Attributes | Foreign Keys |
| :--- | :--- | :--- | :--- |
| CLIENT | `ClientID` | `ClientID`, `ClientName`, `TaxCode`, `RepresentativeName`, `Email`, `Street`, `Ward`, `District`, `City` | *None* |
| CLIENT_PHONE | `ClientID`, `ContactPhone` | `ClientID`, `ContactPhone` | `ClientID -> CLIENT(ClientID)` |
| PROJECT | `ProjectID` | `ProjectID`, `ProjectName`, `ContractNumber`, `EstimatedBudget`, `ActualCost`, `StartDate`, `ScheduledEndDate`, `ActualEndDate`, `Status`, `ClientID`, `DeptID`, `DirectorEmpID` | `ClientID -> CLIENT(ClientID)`; `DeptID -> DEPARTMENT(DeptID)`; `DirectorEmpID -> EMPLOYEE(EmpID)` |
| PROJECT_SITE | `SiteID` | `SiteID`, `SiteName`, `Street`, `Ward`, `District`, `City`, `Latitude`, `Longitude`, `ProjectID` | `ProjectID -> PROJECT(ProjectID)` |
| PROJECT_PHASE | `ProjectID`, `PhaseNumber` (partial key) | `ProjectID`, `PhaseNumber`, `PhaseName`, `PhaseBudget`, `StartDate`, `ScheduledEndDate`, `ActualEndDate`, `Status`, `ProgressPercentage` | `ProjectID -> PROJECT(ProjectID)` |
| TASK | `TaskID` | `TaskID`, `TaskName`, `Description`, `EstimatedCost`, `ActualCost`, `StartDate`, `EndDate`, `Status`, `ProjectID`, `PhaseNumber` | `(ProjectID, PhaseNumber) -> PROJECT_PHASE(ProjectID, PhaseNumber)` |
| PRECEDES | `PredecessorTaskID`, `SuccessorTaskID` | `PredecessorTaskID`, `SuccessorTaskID` | `PredecessorTaskID -> TASK(TaskID)`; `SuccessorTaskID -> TASK(TaskID)` |
| WORKS_ON_TASK | `EmpID`, `TaskID` | `EmpID`, `TaskID`, `HoursLogged`, `RoleDescription`, `AssignedDate` | `EmpID -> EMPLOYEE(EmpID)`; `TaskID -> TASK(TaskID)` |

### 7.2.3 Equipment

`EQUIPMENT` retains `TotalRunHours` as a materialized meter total, `MAINTENANCE_RECORD` inherits `EquipmentID` with partial key `RecordNumber`, and `EQUIPMENT_DEPLOYMENT` adds `OperatorEmpID` from the `OPERATES` aggregation relationship.

| Table | Primary Key | Attributes | Foreign Keys |
| :--- | :--- | :--- | :--- |
| EQUIPMENT | `EquipmentID` | `EquipmentID`, `SerialNumber`, `EquipmentName`, `Category`, `Capacity`, `HourlyRate`, `Status`, `TotalRunHours` | *None* |
| MAINTENANCE_RECORD | `EquipmentID`, `RecordNumber` (partial key) | `EquipmentID`, `RecordNumber`, `MaintenanceDate`, `MaintenanceType`, `Description`, `Cost`, `PerformedBy` | `EquipmentID -> EQUIPMENT(EquipmentID)` |
| EQUIPMENT_DEPLOYMENT | `EquipmentID`, `SiteID`, `DeploymentStartDate` | `EquipmentID`, `SiteID`, `DeploymentStartDate`, `DeploymentEndDate`, `OperatingHours`, `OperatorEmpID` | `EquipmentID -> EQUIPMENT(EquipmentID)`; `SiteID -> PROJECT_SITE(SiteID)`; `OperatorEmpID -> EMPLOYEE(EmpID)` |

### 7.2.4 Materials and procurement

`SUPPLIER` expands composite `Address`, `SUPPLIER_PHONE` and `SUPPLIER_CATEGORY` extract multi-valued supplier attributes, `ItemSubtotal` is omitted as derived while `PURCHASE_ORDER.TotalAmount` is materialized, `DELIVERY_DISPATCH` adds `PO_ID` (`FULFILLS_PO`) and `ReceivedByEmpID` (`RECEIVES_DELIVERY`) from aggregation links alongside `SupplierID` from the ternary mapping, and `MATERIAL_USAGE` maps the ternary consumption relationship.

| Table | Primary Key | Attributes | Foreign Keys |
| :--- | :--- | :--- | :--- |
| SUPPLIER | `SupplierID` | `SupplierID`, `SupplierName`, `TaxCode`, `Email`, `Street`, `Ward`, `District`, `City` | *None* |
| SUPPLIER_PHONE | `SupplierID`, `ContactPhone` | `SupplierID`, `ContactPhone` | `SupplierID -> SUPPLIER(SupplierID)` |
| SUPPLIER_CATEGORY | `SupplierID`, `SupplyCategory` | `SupplierID`, `SupplyCategory` | `SupplierID -> SUPPLIER(SupplierID)` |
| MATERIAL | `MaterialID` | `MaterialID`, `MaterialName`, `Unit`, `StandardPrice` | *None* |
| PURCHASE_ORDER | `PO_ID` | `PO_ID`, `OrderDate`, `TotalAmount`, `Status`, `ProjectID`, `SupplierID` | `ProjectID -> PROJECT(ProjectID)`; `SupplierID -> SUPPLIER(SupplierID)` |
| PO_ITEM | `PO_ID`, `LineNumber` (partial key) | `PO_ID`, `LineNumber`, `OrderQuantity`, `UnitPrice`, `MaterialID` | `PO_ID -> PURCHASE_ORDER(PO_ID)`; `MaterialID -> MATERIAL(MaterialID)` |
| SITE_INVENTORY | `SiteID`, `MaterialID` | `SiteID`, `MaterialID`, `CurrentStockQuantity`, `MinStock`, `ReorderQuantity` | `SiteID -> PROJECT_SITE(SiteID)`; `MaterialID -> MATERIAL(MaterialID)` |
| DELIVERY_DISPATCH | `DeliveryCode` | `DeliveryCode`, `DeliveryDate`, `DeliveredQuantity`, `Status`, `MaterialID`, `SiteID`, `ReceivedByEmpID`, `PO_ID`, `SupplierID` | `SupplierID -> SUPPLIER(SupplierID)`; `MaterialID -> MATERIAL(MaterialID)`; `SiteID -> PROJECT_SITE(SiteID)`; `ReceivedByEmpID -> EMPLOYEE(EmpID)`; `PO_ID -> PURCHASE_ORDER(PO_ID)` |
| MATERIAL_USAGE | `TaskID`, `MaterialID`, `SiteID`, `UsageDate` | `TaskID`, `MaterialID`, `SiteID`, `UsageDate`, `UsedQuantity` | `TaskID -> TASK(TaskID)`; `MaterialID -> MATERIAL(MaterialID)`; `SiteID -> PROJECT_SITE(SiteID)` |

### 7.2.5 Subcontractors

`ENGAGES_SUBCONTRACTOR` maps to `SUBCONTRACT`, keyed by `ContractAgreementNo` and referencing both `PROJECT` and `SUBCONTRACTOR`.

| Table | Primary Key | Attributes | Foreign Keys |
| :--- | :--- | :--- | :--- |
| SUBCONTRACTOR | `SubcontractorID` | `SubcontractorID`, `SubcontractorName`, `TaxCode`, `Specialization`, `ContactPerson`, `ContactPhone`, `ContactEmail`, `LicenseNumber` | *None* |
| SUBCONTRACT | `ContractAgreementNo` | `ContractAgreementNo`, `ProjectID`, `SubcontractorID`, `ScopeOfWork`, `ContractValue`, `WarrantyHoldRate`, `StartDate`, `EndDate` | `ProjectID -> PROJECT(ProjectID)`; `SubcontractorID -> SUBCONTRACTOR(SubcontractorID)` |

### 7.2.6 Safety

Both safety tables inherit `SiteID` from `PROJECT_SITE`. `SAFETY_INSPECTION` stores non-null `InspectorEmpID`, whereas `INCIDENT_REPORT` holds nullable `InvolvedEmpID` and `DamagedEquipmentID` reflecting partial participation on `INVOLVES_EMPLOYEE` and `DAMAGES_EQUIPMENT`.

| Table | Primary Key | Attributes | Foreign Keys |
| :--- | :--- | :--- | :--- |
| SAFETY_INSPECTION | `InspectionID` | `InspectionID`, `InspectionDate`, `InspectionType`, `InspectionScope`, `OverallScore`, `InspectionResult`, `ViolationNoted`, `FixDeadline`, `SiteID`, `InspectorEmpID` | `SiteID -> PROJECT_SITE(SiteID)`; `InspectorEmpID -> EMPLOYEE(EmpID)` |
| INCIDENT_REPORT | `IncidentID` | `IncidentID`, `IncidentTimestamp`, `IncidentType`, `IncidentLevel`, `DamageDescription`, `LostDays`, `Solution`, `SiteID`, `InvolvedEmpID`, `DamagedEquipmentID` | `SiteID -> PROJECT_SITE(SiteID)`; `InvolvedEmpID -> EMPLOYEE(EmpID)`; `DamagedEquipmentID -> EQUIPMENT(EquipmentID)` |
