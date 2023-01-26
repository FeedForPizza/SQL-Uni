USE TestBase
GO 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--��� ������� �� ��� ��������� ���������, �� ��� �� ���� ������
IF OBJECT_ID(N'[19118133].[SP_FIX_CREDITS_WITHOUT_SCHEDULE]', N'P') IS NOT NULL
BEGIN
 drop procedure [19118133].[SP_FIX_CREDITS_WITHOUT_SCHEDULE]
END
GO

--��������� �� ������ �� ��� �������
create procedure [19118133].[SP_FIX_CREDITS_WITHOUT_SCHEDULE]
@CREDIT_NO int,
@CREDIT_BEGIN_DATE date,
@CREDIT_END_DATE date,
@CREDIT_SUM decimal(20,10),
@CREDIT_INTEREST_PRC decimal(20,10),
@CREDIT_ISNTALLMENTS_CNT int
as
BEGIN 
DECLARE C CURSOR 
FOR
SELECT CREDIT_INTEREST_PRC,CREDIT_SUM,CREDIT_ISNTALLMENTS_CNT,CREDIT_BEGIN_DATE
FROM DATA.CREDIT 
WHERE CREDIT_NO NOT IN (SELECT CREDIT_NO FROM DATA.REPAYMENT_SCHEDULE)

FETCH NEXT C INTO 
@CREDIT_INTEREST_PRC,@CREDIT_SUM,@CREDIT_ISNTALLMENTS_CNT,@CREDIT_BEGIN_DATE

WHILE @@FETCH_STATUS =0 
BEGIN
	INSERT INTO [19118133].REPAYMENT_SCHEDULE(CREDIT_NO,INSTALLMENT_NO,INSTALLMENT_DATE,INSTALLMENT_SUM,INSTALLMENT_PRINCIPLE,
		INSTALLMENT_INTEREST,INSTALLMENT_RESTSUM)
		SELECT @CREDIT_NO,
		ROW_NUMBER() OVER(ORDER BY installmentDate),*
		FROM DATA.[UF_GEN_REPAYMENT_SCHEDULE](@CREDIT_INTEREST_PRC,@CREDIT_SUM,@CREDIT_ISNTALLMENTS_CNT,@CREDIT_BEGIN_DATE);
		FETCH NEXT C INTO 
@CREDIT_INTEREST_PRC,@CREDIT_SUM,@CREDIT_ISNTALLMENTS_CNT,@CREDIT_BEGIN_DATE
END
CLOSE C;
DEALLOCATE C;
END
GO

CREATE TABLE [19118133].PAYMENTS 
(CREDIT_NO numeric(18,0) NOT NULL,
PAYMENT_DATE DATE NOT NULL,
PAYMENT_SUM numeric(10,2) NOT NULL)


IF OBJECT_ID(N'[19118133].[UF_GET_PAYED_SUM]', N'FN') IS NOT NULL
BEGIN
drop function [19118133].[UF_GET_PAYED_SUM]
END
GO

CREATE FUNCTION [19118133].UF_GET_PAYED_SUM	(@credit_no numeric(18,0))
RETURNS numeric(10,2)
as 
BEGIN
DECLARE @allSum numeric(10,2)
SELECT	@allSum = (SELECT COUNT(*) FROM [19118133].CREDIT WHERE CREDIT_NO=@credit_no) * PAYMENT_SUM
FROM [19118133].PAYMENTS 
WHERE CREDIT_NO = @credit_no
RETURN @allSum
END
GO


ALTER TABLE [19118133].CREDIT
ADD CREDIT_PAYED_SUM AS [19118133].UF_GET_PAYED_SUM(CREDIT_NO)


