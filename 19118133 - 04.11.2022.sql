--����� �� ���� �����
USE [TestBase]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--��� ������� �� ��� �������� ������� ����������, �� ��� �� ���� ������
IF OBJECT_ID(N'[19118133].[UF_CREDIT_SUM]', N'FN') IS NOT NULL
BEGIN
 drop function [19118133].[UF_CREDIT_SUM]
END
GO
--��� ������� �� ��� table-valued ������� ����������, �� ��� �� ���� ������
IF OBJECT_ID(N'[19118133].[UF_CREDIT_SUM]', N'IF') IS NOT NULL
BEGIN
 drop function [19118133].[UF_CREDIT_SUM]
END
GO
--��������� �� ������ �� ��� �������
create function [19118133].[UF_CREDIT_SUM]()
RETURNS TABLE
as
RETURN (SELECT CREDIT_NO, SUM(INSTALLMENT_SUM) AS TOTAL_SUM
		FROM DATA.REPAYMENT_SCHEDULE RS
		GROUP BY CREDIT_NO);


--��� ������� ���������� �� ��� ������, �� ��� �� ���� ������
IF OBJECT_ID(N'[19118133].[V_CHECK_CREDIT_SUM]', N'V') IS NOT NULL
BEGIN
 drop view [19118133].[V_CHECK_CREDIT_SUM]
END
GO
--��������� �� ������ �� ��� ������
create view [19118133].[V_CHECK_CREDIT_SUM]
as
SELECT  DISTINCT C.CREDIT_NO,
		C.CREDIT_ALLSUM AS CREDIT_SUM,
		F.TOTAL_SUM AS TOTAL_SUM,
		(C.CREDIT_ALLSUM - F.TOTAL_SUM) AS DIFF
FROM DATA.CREDIT C INNER JOIN [19118133].[UF_CREDIT_SUM]() F ON F.CREDIT_NO = C.CREDIT_NO
WHERE  (C.CREDIT_ALLSUM - F.TOTAL_SUM) <> 0 