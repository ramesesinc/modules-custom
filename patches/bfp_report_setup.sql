INSERT INTO account_maingroup (objid, title, version, reporttype, role, domain, system) 
VALUES ('BFP', 'BFP', '1', 'BFP', NULL, 'BFP', '0');


INSERT INTO account (objid, maingroupid, code, title, groupid, type, leftindex, rightindex, level) 
VALUES ('BFP-04', 'BFP', '04', 'INCOME', NULL, 'root', '0', '5', '1');

INSERT INTO account (objid, maingroupid, code, title, groupid, type, leftindex, rightindex, level) 
VALUES ('BFP-04-01', 'BFP', '04-01', 'SERVICE INCOME', 'BFP-04', 'group', '1', '4', '2');

INSERT INTO account (objid, maingroupid, code, title, groupid, type, leftindex, rightindex, level) 
VALUES ('BFP-04-01-01', 'BFP', '04-01-01', 'FIRE SAFETY INSPECTION FEE', 'BFP-04-01', 'item', '2', '3', '3');


INSERT INTO sys_usergroup (objid, title, domain, userclass, orgclass, role) 
VALUES ('BFP.REPORT', 'BFP REPORT', 'BFP', NULL, NULL, 'REPORT');
