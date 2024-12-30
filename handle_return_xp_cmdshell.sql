--
--  Created by John Medeiros.
--  e-mail: 
--  Date: 2014
--
-- The code described below, shows how to handle errors returned by xp_cmdshell routine.
-- SQL Server versions: 2005 and above.
--

SET NOCOUNT ON;

DECLARE
  @v_BCP_Command VARCHAR(4000), -- BCP Command
  @v_cmdshell_return_code INT, -- Return code from xp_cmdshell
  @v_cmdshell_raiserror_text VARCHAR(4000); -- Lines returned by xp_cmdshell output.
    
-- Stores output return from xp_cmdshell.
DECLARE @t_cmdshell_output_table_result TABLE 
  (
    output_result VARCHAR(255) 
  );

-- Example
SET @v_BCP_Command = 'dir /w'; 
    
-- Use this if you have xp_cmdshell several times in your code, only to ensure correct output.
DELETE FROM @t_cmdshell_output_table_result; 

-- Get output values and put them into @t_cmdshell_output_table_result variable to process in the next step.
INSERT INTO @t_cmdshell_output_table_result  
  (output_result)
EXECUTE @v_cmdshell_return_code = xp_cmdshell @v_BCP_Command;

-- Only if the return code is different from 0, we need to treat the output text.
IF (@v_cmdshell_return_code<>0)
  BEGIN

    -- I particularly use this block for a self explanatory message.
    SET @v_cmdshell_raiserror_text = 'cmdshell Error:';

    -- Reads all lines returned from xp_cmdshell and concatenates to transform in a message to be raised.
    SELECT 
      @v_cmdshell_raiserror_text = COALESCE(@v_cmdshell_raiserror_text + CHAR(10), '') + output_result 
    FROM 
      @t_cmdshell_output_table_result
    WHERE 
      output_result IS NOT NULL;

    -- Raises the exception to caller.
    RAISERROR(@v_cmdshell_raiserror_text, 16,1) WITH NOWAIT;
  END;      
