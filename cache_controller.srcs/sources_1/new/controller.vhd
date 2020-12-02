----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Stian Onarheim
-- 
-- Create Date: 12/02/2020 06:55:34 PM
-- Design Name: 
-- Module Name: controller - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller is
    Port ( readOrWrite : in STD_LOGIC;
           validCpuRequest : in STD_LOGIC;
           address : in STD_LOGIC_VECTOR (31 downto 0);
           ptcData : in STD_LOGIC_VECTOR (31 downto 0);
           ctpData : out STD_LOGIC_VECTOR (31 downto 0);
           cacheReady : out STD_LOGIC;
           clk : in STD_LOGIC);
end controller;

architecture Behavioral of controller is

type WORD is array (0 to 3) of STD_LOGIC_VECTOR (31 downto 0);

type BLOCK is record
	valid_bit : STD_LOGIC;
	dirty_bit : STD_LOGIC;
	tag : STD_LOGIC_VECTOR (17 downto 0);
	data : WORD;
end record BLOCK;

type CACHE_1024 is array (0 to 1023) of BLOCK;
variable cache : CACHE_1024 := (others => (
	valid_bit => '0';
	dirty_bit => '0';
	tag => (others => '0');
	data => (others => (others => '0'));
	));

type FSM is (Idle, Compare_Tag, Allocate, Write_Back);
signal state_reg, state_next : FSM;
signal memoryIsReady : BOOLEAN;
signal currentBlock : INTEGER;
signal currentTag : STD_LOGIC_VECTOR (17 downto 0);
signal currentBlockOffset : INTEGER;

begin

process (clk)
begin
	if rising_edge(clk) then
		state_reg <= state_next;
	end if;
end process;

process (state_reg, valid)
begin
	state_next <= state_reg;
	case state_reg is
		when Allocate =>
			-- Read new block from Memory
			if memoryIsReady then
				state_next <= Compare_Tag;
			end if;
		when Compare_Tag =>
			if cache(currentBlock).valid_bit = '1' and currentTag = cache(currentBlock).tag then
				if readOrWrite = '1' then
					ctpData <= cache(currentBlock).data(currentBlockOffset);
					cache(currentBlock).dirty_bit <= '0';
				else
					cache(currentBlock).data(currentBlockOffset) <= ptcData;
					cache(currentBlock).dirty_bit <= '1';
				end if;
				cacheReady <= '1';
				state_next <= Idle;
			elsif cache(currentBlock).dirty_bit = '1' then
				state_next <= Write_Back;
			else
				state_next <= Allocate;
			end if;
			cache(currentBlock).valid_bit <= '1';
			cache(currentBlock).tag <= currentTag;
		when Idle =>
			if validCpuRequest = '1' then
				state_next <= Compare_Tag;
			end if;
		when Write_Back =>
			if memoryIsReady then
				-- Write Old Block to Memory
				state_next <= Allocate;
			end if;
				
	end case;

end process;

end Behavioral;
