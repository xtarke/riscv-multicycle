--------------------------------------------------------------------------------
-- TODO "External compiler/simulator"
--      If you have a supported simulator installed, Sigasi Studio can
--      automatically compile your files and prepare them for simulation.
--
-- * Step 1 : Configure the path of your compiler via 
--   **Window > Preferences > Sigasi > Toolchains > Your simulator**
-- * Step 2 : Enable your compiler via
--   **Window > Preferences > Sigasi > Toolchains**
--
-- Once enabled, everytime you save a file, Sigasi Studio will compile this 
-- file with the external compiler too.
--------------------------------------------------------------------------------

library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

--------------------------------------------------------------------------------
-- TODO "External simulation"
--      Before you can run a simulation, you need to set a top level.
--
-- * Step 1 : Right click on `testbench` and select **Set as Top Level**
-- * Step 2 : In the **Hierarchy View**, click the **Start Simulation** button.
--------------------------------------------------------------------------------

entity testbench is
end entity testbench;
