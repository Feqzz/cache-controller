----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/05/2020 04:42:39 PM
-- Design Name: 
-- Module Name: system_tb - Behavioral
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

entity system_tb is
--  Port ( );
end system_tb;

architecture Behavioral of system_tb is

component system is
    Port (  ptcReadOrWrite : in STD_LOGIC;
            validCpuRequest : in STD_LOGIC;
            address : in STD_LOGIC_VECTOR (31 downto 0);
            ptcData : in STD_LOGIC_VECTOR (31 downto 0);
            ctpData : out STD_LOGIC_VECTOR (31 downto 0);
            cacheReady : out STD_LOGIC;
            clk : in STD_LOGIC);
end component system;

signal ptcReadOrWrite_tb, validCpuRequest_tb, cacheReady_tb, clk_tb : STD_LOGIC;
signal address_tb, ptcData_tb, ctpData_tb : STD_LOGIC_VECTOR (31 downto 0);
constant clk_period : time := 4 ns;

begin

UUT: system
port map (ptcReadOrWrite => ptcReadOrWrite_tb, validCpuRequest => validCpuRequest_tb,
address => address_tb, ptcData => ptcData_tb, ctpData => ctpData_tb,
cacheReady => cacheReady_tb, clk => clk_tb);

process
begin
    clk_tb <= '1';
    wait for (clk_period / 2);
    clk_tb <= '0';
    wait for (clk_period / 2);
end process;

process
begin
--    ptcReadOrWrite_tb <= '1';
--    address_tb <= "00000000000000000100000000000000";
--    validCpuRequest_tb <= '1';
--    wait for 100 ns;
--    validCpuRequest_tb <= '0';
    ptcReadOrWrite_tb <= '0';
    address_tb <= "00000000000000000100000000000000";
    ptcData_tb <= "10101010101010101010101010101010";
    validCpuRequest_tb <= '1';
    wait for 100 ns;
    ptcReadOrWrite_tb <= '0';
    address_tb <= "00000000000000001100000000000000";
    ptcData_tb <= "10101010101110101011101010101011";
    validCpuRequest_tb <= '1';
    wait;
end process;


end Behavioral;
