--------------------------------------------------------------------------------
-- Welcome! --
--------------------------------------------------------------------------------
-- You made a great choice installing Sigasi Studio, and now you are ready to
-- unlock its power.
--
-- This demo file will guide you on your first steps. In a few minutes you will
-- have learned the basics of how Sigasi Studio helps you work with VHDL files. 
--
-- Just follow the comments below that are marked 'TODO'.

--------------------------------------------------------------------------------
-- TODO "Format"
--      Sigasi Studio can clean up, or format, your VHDL code. This can greatly
--      enhance the readability of your code. Click **Edit > Format** or
--      **Shift+Ctrl+F** to format the current selection. If you select no text,
--      Sigasi Studio will format the entire file.
--------------------------------------------------------------------------------

library ieee; use ieee.std_logic_1164.all;

entity welcome is     port(
clk:in std_logic; -- This is the main clock
rst:in std_logic;
data_in:in std_logic;
data_out:out std_logic
);end entity welcome;

architecture RTL of welcome is
type mytype is (a, b, c);
                signal state : mytype;
begin
	
--------------------------------------------------------------------------------
-- TODO "Hover"
--      In the line below, hover your mouse over the word 'clk'. Notice how the
--      data type, direction and comments of this port shows up in a pop-up.  
--      Go ahead and hover over other things too!
--
--------------------------------------------------------------------------------

-- the main process of this architecture
name : process(clk) is begin

--------------------------------------------------------------------------------
-- TODO "Syntax error"
--      In the line below, Sigasi Studio reports a syntax error. Indeed, in VHDL
--      you have to use `=` instead of `==` for *equals*.  
--      Remove the extra `=` and note how the Error Marker disappears.
--------------------------------------------------------------------------------
	
if (rst  == '1') then
			
elsif rising_edge(clk) then
	
--------------------------------------------------------------------------------
-- TODO "Autcomplete"
--      Sigasi Studio can help you to type VHDL code faster. On the line below,
--      type `case`, press **CTRL+Space** and confirm with **Enter**.  
--      Note how Sigasi inserts a case stament with choices for each of the enum
--      choices of the local signal `state`.
--------------------------------------------------------------------------------

		        

--------------------------------------------------------------------------------
-- TODO "Quickfix"
--      On the line below, we typed a syntax error (data_out is a port so the
--      `<=` assignment must be used). Note that the error marker in the gutter
--      has a small light bulb icon. Click on the light bulb and select
--      **Fix Assignment Operator**.  
--      Note how the error gets automatically fixed.
--------------------------------------------------------------------------------
data_out := data_in;
end if;
end process name;

end architecture RTL;

--------------------------------------------------------------------------------
-- TODO "Open your own file"
--      Now that you know the first basics about editing in Sigasi Studio, open
--      your own VHDL file in single file mode:  
--      **Drag and drop** your file into this editor from your file explorer,
--      or click **File > Open File ...**
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- TODO If you don't have a Sigasi Studio license,
--      request your trial license at <http://www.sigasi.com/try> 
-- 
--      Next, we invite you to continue this tutorial. To do so:
--      Double click the `step_2.vhd` file in the **Project Explorer**
--------------------------------------------------------------------------------
