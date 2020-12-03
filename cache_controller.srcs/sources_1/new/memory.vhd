----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/03/2020 07:23:42 PM
-- Design Name: 
-- Module Name: memory - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity memory is
    Port ( readOrWrite : in STD_LOGIC;
           validSignal : in STD_LOGIC;
           address : in STD_LOGIC_VECTOR (31 downto 0);
           ctmData : in STD_LOGIC_VECTOR (127 downto 0);
           mtcData : out STD_LOGIC_VECTOR (127 downto 0);
           memoryReady : out STD_LOGIC_VECTOR (0 downto 0));
end memory;

architecture Behavioral of memory is

begin


end Behavioral;
