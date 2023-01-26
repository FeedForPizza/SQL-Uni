--Избор на база данни
USE [TestBase]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Ако обектът от тип скаларна функция съществува, то той да бъде изтрит
IF OBJECT_ID(N'[19118133].[UF_CHECK_CREDIT_INSTALLMENT_CNT_DIFF]', N'FN') IS NOT NULL
BEGIN
 drop function [19118133].[UF_CHECK_CREDIT_INSTALLMENT_CNT_DIFF]
END
GO
--Ако обектът от тип table-valued функция съществува, то той да бъде изтрит
IF OBJECT_ID(N'[19118133].[UF_CHECK_CREDIT_INSTALLMENT_CNT_DIFF]', N'IF') IS NOT NULL
BEGIN
 drop function [19118133].[UF_CHECK_CREDIT_INSTALLMENT_CNT_DIFF]
END
GO
--Създаване на обекта от тип функция


create function [19118133].[UF_CHECK_CREDIT_INSTALLMENT_CNT_DIFF] (@creditNO numeric(18,0))
RETURNS int 
AS 
BEGIN 
	DECLARE @diff int 
	SELECT @diff = C.CREDIT_ISNTALLMENTS_CNT - (SELECT COUNT(*)
												FROM DATA.REPAYMENT_SCHEDULE RS
												WHERE RS.CREDIT_NO = C.CREDIT_NO) 
	FROM DATA.CREDIT C
	WHERE C.CREDIT_NO = @creditNO
	RETURN @diff
END


--Ако обектът от тип съхранена процедура, то той да бъде изтрит
IF OBJECT_ID(N'[19118133].[SP_FIX_CREDIT_ERRORS]', N'P') IS NOT NULL
BEGIN
 drop procedure [19118133].[SP_FIX_CREDIT_ERRORS]
END
GO
--Създаване на обекта от тип функция
create procedure [19118133].[SP_FIX_CREDIT_ERRORS]
@credit_no numeric(18,0)
as
BEGIN
DECLARE @DIFF INT = [19118133].UF_CHECK_CREDIT_INSTALLMENT_CNT_DIFF(@credit_no),@RS_COUNT INT = (SELECT COUNT(INSTALLMENT_NO)
						FROM DATA.REPAYMENT_SCHEDULE RS 
						WHERE RS.CREDIT_NO = @credit_no)
IF NOT EXISTS (SELECT *
			FROM DATA.CREDIT
			WHERE CREDIT_NO = @credit_no )
RETURN -1 
ELSE 

		UPDATE [19118133].CREDIT
		SET CREDIT_ISNTALLMENTS_CNT = @RS_COUNT
		WHERE CREDIT_NO = @credit_no
						AND @DIFF <> 0 
END
RETURN 0 

