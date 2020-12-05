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
	Port ( ptcReadOrWrite : in STD_LOGIC;
		   validCpuRequest : in STD_LOGIC;
		   ptcAddress : in STD_LOGIC_VECTOR (31 downto 0);
		   ptcData : in STD_LOGIC_VECTOR (31 downto 0);
		   ctpData : out STD_LOGIC_VECTOR (31 downto 0);
		   cacheReady : out STD_LOGIC;
		   ctmReadOrWrite : out STD_LOGIC;
		   ctmAddress : out STD_LOGIC_VECTOR (31 downto 0);
		   ctmData : out STD_LOGIC_VECTOR (127 downto 0);
		   mtcData : in STD_LOGIC_VECTOR (127 downto 0);
		   validCacheRequest : out STD_LOGIC;
		   memoryReady : in STD_LOGIC;
		   clk : in STD_LOGIC);
end controller;

architecture Behavioral of controller is

	type WORD is array (0 to 3) of STD_LOGIC_VECTOR (31 downto 0);

	type cache_block is record
		valid_bit : STD_LOGIC;
		dirty_bit : STD_LOGIC;
		tag : STD_LOGIC_VECTOR (17 downto 0);
		data : WORD;
	end record cache_block;

	type CACHE_1024 is array (0 to 1023) of cache_block;
	signal cache : CACHE_1024 := ( others => (
	valid_bit => '0',
	dirty_bit => '0',
	tag => (others => '0'),
	data => (others => (others => '0'))
));

-- The Finite State Machine
type FSM is (Idle, Compare_Tag, Allocate, Write_Back);
signal state_reg, state_next : FSM;

-- The decoded locations.
signal currentTag : STD_LOGIC_VECTOR (17 downto 0);
signal currentBlock : INTEGER;
signal currentBlockOffset : INTEGER;

begin

	-- Forwarding the address from the CPU to the memory.
	-- This can maybe be removed.
	ctmAddress <= ptcAddress;

	--state_reg <= state_next;

	process (clk)
	begin
		if rising_edge(clk) then
			state_reg <= state_next;
		end if;
	end process;

	-- Decodes the address into Tag, Index and block offset.
	process (ptcAddress)
	begin
		currentTag <= ptcAddress(31 downto 14);
		currentBlock <= to_integer(unsigned(ptcAddress(13 downto 4)));
		currentBlockOffset <= to_integer(unsigned(ptcAddress(3 downto 0)));
	end process;

	process (state_reg, validCpuRequest, memoryReady)
	begin
		--state_next <= state_reg;
		case state_reg is
			when Allocate =>
				-- This needs to be here, or simulation will crash.
				if state_reg = state_next then
					-- Signal that we want to read from the Memory and that the signal is valid.
					ctmReadOrWrite <= '1';
					validCacheRequest <= '1';
					if memoryReady = '1' then
						-- Read new block from Memory and overwrite the current block.
						cache(currentBlock).data(3) <= mtcData(127 downto 96);
						cache(currentBlock).data(2) <= mtcData(95 downto 64);
						cache(currentBlock).data(1) <= mtcData(63 downto 32);
						cache(currentBlock).data(0) <= mtcData(31 downto 0);
						-- We are done reading, so we remove the valid request signal. 
						validCacheRequest <= '0';
						-- We update the block to valid and its current tag.
						cache(currentBlock).valid_bit <= '1';
						cache(currentBlock).tag <= currentTag;
						-- Done!			         
						state_next <= Compare_Tag;
					end if;
				end if;
			when Compare_Tag =>
				if cache(currentBlock).valid_bit = '1' and currentTag = cache(currentBlock).tag then
					if ptcReadOrWrite = '1' then
						ctpData <= cache(currentBlock).data(currentBlockOffset);
						cache(currentBlock).dirty_bit <= '0';
					else
						cache(currentBlock).data(currentBlockOffset) <= ptcData;
						-- The new data is now stored in the cache, but not in the memory. Hence the dirty bit.
						cache(currentBlock).dirty_bit <= '1';
						-- As there now exists data on this block, the valid bit and tag is updated.
						cache(currentBlock).valid_bit <= '1';
						cache(currentBlock).tag <= currentTag;
					end if;
					cacheReady <= '1';
					state_next <= Idle;
				elsif cache(currentBlock).dirty_bit = '1' then
					state_next <= Write_Back;
				else
					state_next <= Allocate;
				end if;
			when Idle =>
				if validCpuRequest = '1' then
					state_next <= Compare_Tag;
				else
					cacheReady <= '0';
				end if;
			when Write_Back =>
				-- Signal that we want to write to the Memory and that the signal is valid.
				ctmReadOrWrite <= '0';
				-- Update the cache-to-memory databus.
				ctmData(127 downto 96) <= cache(currentBlock).data(3);
				ctmData(95 downto 64) <= cache(currentBlock).data(2);
				ctmData(63 downto 32) <= cache(currentBlock).data(1);
				ctmData(31 downto 0) <= cache(currentBlock).data(0);
				-- The databus is now updated, and we can signal that we have done our part.
				validCacheRequest <= '1';
				if memoryReady = '1' then
					-- The request has been fulfilled! We can now toggle off the valid signal.
					validCacheRequest <= '0';
					state_next <= Allocate;
				end if;		
		end case;
	end process;

end Behavioral;
