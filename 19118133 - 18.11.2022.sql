--Избор на база данни
USE [TestBase]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Ако обектът от тип съхранена процедура, то той да бъде изтрит
IF OBJECT_ID(N'[19118133].[SP_GEN_REPAYMENT_SCHEDULE]', N'P') IS NOT NULL
BEGIN
 drop procedure [19118133].[SP_GEN_REPAYMENT_SCHEDULE]
END
GO

--Създаване на обекта от тип процедура
create procedure [19118133].[SP_GEN_REPAYMENT_SCHEDULE]
@CREDIT_NO int,
@CREDIT_BEGIN_DATE date,
@CREDIT_END_DATE date,
@CREDIT_SUM decimal(20,10),
@CREDIT_INTEREST_PRC decimal(20,10),
@CREDIT_ISNTALLMENTS_CNT int
as
BEGIN 
	DECLARE @msg nvarchar(50), @CREDIT_FIRST_MATURITY date,@rownum int
	SET @CREDIT_FIRST_MATURITY = DATEADD(MONTH,1,@CREDIT_FIRST_MATURITY)
	IF NOT EXISTS(SELECT CREDIT_NO
				FROM DATA.CREDIT
				WHERE CREDIT_NO = @CREDIT_NO) 
					BEGIN  
						SET @msg = N'Подаденият номер на кредит не съществува';
						RAISERROR(@msg,16,1)
						RETURN
					END 
	ELSE IF @CREDIT_END_DATE < @CREDIT_BEGIN_DATE 
		BEGIN  
				SET @msg = N'Началната дата трябва да е преди крайната дата  на кредита';
				RAISERROR(@msg,16,1)
				RETURN
		END 
	ELSE IF DATEDIFF(MONTH,@CREDIT_BEGIN_DATE,@CREDIT_END_DATE) != (SELECT COUNT(*)
					FROM DATA.REPAYMENT_SCHEDULE
					WHERE CREDIT_NO = @CREDIT_NO)
				BEGIN  
						SET @msg = N'Броят на вноските по кредита не отговаря интервала между началната дата и крайната дата на кредита.';
						RAISERROR(@msg,16,1)
						RETURN
				END 
	ELSE IF @CREDIT_SUM < 1000 
		BEGIN  
				SET @msg = N'Сумата на кредита трябва да е минимум 1000.';
				RAISERROR(@msg,16,1)
				RETURN
		END 
	ELSE IF @CREDIT_INTEREST_PRC != 0 AND @CREDIT_INTEREST_PRC < 0
		BEGIN  
				SET @msg = N'Лихвеният процент трябва да е положително число';
				RAISERROR(@msg,16,1)
				RETURN
		END
	ELSE IF @CREDIT_ISNTALLMENTS_CNT < 12 
		BEGIN  
				SET @msg = N'Броят на вноските трябва да е по-голям или равен на 12';
				RAISERROR(@msg,16,1)
				RETURN
		END
	ELSE 
		INSERT INTO [19118133].REPAYMENT_SCHEDULE(CREDIT_NO,INSTALLMENT_NO,INSTALLMENT_DATE,INSTALLMENT_SUM,INSTALLMENT_PRINCIPLE,
		INSTALLMENT_INTEREST,INSTALLMENT_RESTSUM)
		SELECT @CREDIT_NO,
		ROW_NUMBER() OVER(ORDER BY installmentDate),*
		FROM DATA.[UF_GEN_REPAYMENT_SCHEDULE](@CREDIT_INTEREST_PRC,@CREDIT_SUM,@CREDIT_ISNTALLMENTS_CNT,@CREDIT_BEGIN_DATE);
		END
		GO
