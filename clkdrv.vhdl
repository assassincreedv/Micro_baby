LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY clkdrv IS
  PORT(mclk : OUT std_logic;
       clk  : OUT std_logic);
END clkdrv;

ARCHITECTURE one OF clkdrv IS
  SIGNAL imclk,iclk,iclk2 : std_logic := '0';
BEGIN
  PROCESS(imclk,iclk)
  BEGIN
    IF (imclk='1' and imclk'event) THEN iclk <= NOT iclk; END IF;
    IF (iclk='1' and iclk'event) THEN iclk2 <= NOT iclk2; END IF;
    clk <= iclk2;
  END PROCESS;

  imclk <= NOT imclk AFTER 5 ns;

  mclk <= imclk;
END one;