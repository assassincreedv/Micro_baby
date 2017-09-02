LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY mbctl IS
  PORT(stld : OUT std_logic;
       ldcmpl : IN std_logic;
       Dbus : IN std_logic_vector(7 downto 0);
       addr : OUT std_logic_vector(7 downto 0);
       rst : IN std_logic;
       clk,mclk : IN std_logic;
       rw,ice : OUT std_logic;
       dce : OUT std_logic;
       Aal,Bbu,Bmltch,Ldacc,Dracc,AddSub,Arlo : OUT std_logic;
       Csel : OUT std_logic_vector(1 downto 0);
       Funct : OUT std_logic_vector(3 downto 0);
       C,N,Z : IN std_logic;
       CtlCout : OUT std_logic);
END mbctl;

ARCHITECTURE one OF mbctl IS
  TYPE state_type IS (reset,loading,f1,f2,f3,f4,f5,f6,f7,f8,e1,e2,e3,e4,e5,e6,e7,e8,e21,e22,e23,e24,e25,e26,e27,e28);
  SIGNAL state,next_state : state_type;
  --declare signals for internal units
  SIGNAL pc,ir,tmpaddrreg : std_logic_vector(7 downto 0) := "00000000";
  SIGNAL ldnewpc,pcsel : std_logic;
  --declare control signals for datapath
  SIGNAL dpcsvec,dpcsvec2 : std_logic_vector(0 to 8);
  SIGNAL dpfunvec : std_logic_vector(3 downto 0);
  SIGNAL ecsvec,e2csvec : std_logic_vector(1 to 8);
  SIGNAL memcsvec : std_logic_vector(3 downto 0);
  SIGNAL ic_c,ic_n,ic_z,lflgs,cclr,cset : std_logic := '0';
  --declare internal components
  COMPONENT PCunit IS
    PORT (pc : OUT std_logic_vector(7 downto 0);
          fixval : IN std_logic_vector(7 downto 0);
          pcsel,ldnewpc : IN std_logic;
          rst : IN std_logic);
  END COMPONENT;
  FOR all : pcunit USE ENTITY WORK.PCunit(one);
--------------------------------------------------------------------------
BEGIN

  PROCESS  -- process for setting and clearing of carry
  BEGIN
    WAIT on cset,cclr,lflgs;
    IF lflgs='1' AND lflgs'event THEN ic_c <= C; ic_n <= N; ic_z <= Z; END IF;
    IF cclr='1' AND cclr'event THEN ic_c <= '0'; END IF;
    IF cset='1' AND cset'event THEN ic_c <= '1'; END IF;
  END PROCESS;
  -- carry flag goes back out once latched
  CtlCout <= ic_c;
  ----------------------------------------------------------------
  --FF process to latch next_state to state or set state when rst
  PROCESS (mclk)
  BEGIN
    IF (rst='0') THEN state <= reset;
    ELSIF (mclk'event) THEN state <= next_state;
    END IF;
  END PROCESS;
  
  PROCESS (state,ldcmpl)
  BEGIN
    --FF to latch next_state to state or set state when r
    
    CASE state IS
      WHEN reset => addr <= "ZZZZZZZZ";
                    stld <= '1';
                    rw <= 'Z';
                    ice <= 'Z';
                    dce <= 'Z';
		    next_state <= loading;
                    ldnewpc <= '0';
                    pcsel <= '1';
 	            Bmltch <= '0';
                    Aal <= '0';  Bbu <= '0'; Ldacc <= '0'; Dracc <= '0';
                    AddSub <= '0'; Arlo <= '0'; Csel <= "00";
                    cset <= '0'; cclr <='0'; lflgs <= '0';
      WHEN loading => IF ldcmpl='1' THEN next_state<=f1; stld <= '0' AFTER 5 ns; END IF;
      WHEN f1 => ldnewpc<='0'; cclr <= '0'; cset <= '0'; lflgs <= '0';
                 next_state<=f2;
      WHEN f2 => rw<='0';
                 addr<=pc;
                 next_state<=f3;
      WHEN f3 => ice<='1';
                 dce<='0';
                 next_state<=f4;
      WHEN f4 => ir<=Dbus;
                 next_state<=f5;
      WHEN f5 => next_state<=f6;
      WHEN f6 => 
                 CASE ir IS
                   WHEN "10000001" =>   --LDA Immediate - 2 cycle instr
                     dpcsvec <= "011000000";
                     dpfunvec <= "0000";
                     ecsvec <= "00101000";
                     memcsvec <= "0000";
                   WHEN "10000010" =>  --LDA Direct  - 3 cycle instr
                     dpcsvec <= "000000000";
                     dpcsvec2 <="011000000";
                     dpfunvec <= "0000";
                     ecsvec <= "01001000";
                     e2csvec <= "01000000";
                     memcsvec <= "0100";
                   WHEN "10100010" =>  --STA Direct - 3 cycle instr
                     dpcsvec <= "010100000";
                     dpfunvec <= "0000";
                     ecsvec <= "01001000";
                     memcsvec <= "0110";
                   WHEN "01000001" =>  --Add Immediate
                     dpcsvec <= "101000111";
                     ecsvec <= "00101100";
                   WHEN "01001001" =>  --Add with Carry Immediate
                     dpcsvec <= "101000111";
                     ecsvec <= "00101100";
                   WHEN "01000010" => --Add Direct
                     dpcsvec <= "000000000";
		     dpcsvec2 <= "101000111";
                     ecsvec <= "01001000";
                     e2csvec <= "00101100";
                   WHEN "01010001" =>  --Subtract Immediate
                     dpcsvec <= "101011011";
                     ecsvec <= "00101100";
                   WHEN "01110001" => --Subtract Immediate minus Carry
                     dpcsvec <= "101001011";
                     ecsvec <= "00101100";
                   WHEN "01011001" =>  --AND Immediate
                     dpcsvec <= "101010001";
                     dpfunvec <= "1000";
                     ecsvec <= "00101000";
                   WHEN "01011101" =>  --OR Immediate
                     dpcsvec <= "101010001";
                     dpfunvec <= "1110";
                     ecsvec <= "00101000";
                   WHEN "01010101" =>  --XOR Immediate
                     dpcsvec <= "101010001";
                     dpfunvec <= "0110";
                     ecsvec <= "00101000";
                   WHEN "01000000" =>  --CLRC  Inherent - clear the carry flag
                     dpcsvec <= "000000000";
                     ecsvec <= "00010010";
                   WHEN "01001000" =>  --CSET Inherent - set the carry flag
                     dpcsvec <= "000000000";
                     ecsvec <= "00010001";
                   WHEN OTHERS => null;
                 END CASE;
                 next_state<=f7;
      WHEN f7 => ice <= '0';
                 next_state<=f8;
      WHEN f8 => pcsel <= '1';
                 ldnewpc <= '1';
                 addr<="ZZZZZZZZ";
                 next_state<=e1;
      WHEN e1 => --first execute state
                 next_state<=e2;
                 ldnewpc <= '0';
      WHEN e2 => --second execute state
                 rw <= ecsvec(1);
                 IF ecsvec(2)='1' OR ecsvec(3)='1' THEN addr <= pc; ELSE addr <= "ZZZZZZZZ"; END IF;
                 next_state<=e3;
      WHEN e3 => IF ecsvec(2)='1' OR ecsvec(3)='1' THEN ice<='1'; END IF;
                 Aal <= dpcsvec(0);
                 Bbu <= dpcsvec(1);
                 Csel <= dpcsvec(4 to 5);
                 AddSub <= dpcsvec(6);
                 Arlo <= dpcsvec(7);
                 IF ecsvec(3)='1' THEN Funct<=dpfunvec; END IF;
                 next_state<=e4;
      WHEN e4 => IF dpcsvec(8)='1' THEN Bmltch<='1'; END IF;
                 next_state<=e5;
      WHEN e5 => Bmltch<='0';
                 next_state<=e6;
      WHEN e6 => IF ecsvec(2)='1' THEN tmpaddrreg <= Dbus; END IF;
                 --IF memcsvec(2)='1' THEN tmpaddrreg <= Dbus; END IF;
                 next_state<=e7;
      WHEN e7 => IF (dpcsvec(2)='1') THEN Ldacc <= '1'; END IF;
                 next_state<=e8;
      WHEN e8 => ice <='0'; dce <= '0';
                 Ldacc <= '0';
                 IF (ecsvec(6)='1') THEN lflgs <= '1'; END IF;
                 IF (ecsvec(7)='1') THEN cclr <= '1'; END IF; 
                 IF (ecsvec(8)='1') THEN cset <= '1'; END IF;
                 addr <= "ZZZZZZZZ";
                 IF ecsvec(5)='1' THEN ldnewpc<='1'; END IF;
                 IF ecsvec(2)='1' THEN next_state <= e21; ELSE next_state<=f1; END IF;
      WHEN e21=> ldnewpc <= '0';
                 lflgs <= '0';  cclr<='0'; cset<='0';
                 next_state <= e22;
      WHEN e22=> --second state
                 rw <= memcsvec(1);
                 addr <= tmpaddrreg;
                 IF dpcsvec(3)='1' THEN Dracc<='1'; END IF;
                 next_state <= e23;
      WHEN e23=> dce <= '1';
                 Aal <= dpcsvec2(0);
                 Bbu <= dpcsvec2(1);
                 Csel <= dpcsvec2(4 to 5);
                 AddSub <= dpcsvec2(6);
                 Arlo <= dpcsvec2(7);
                 next_state <= e24;
      WHEN e24=> next_state <= e25;
      WHEN e25=> next_state <= e26;
      WHEN e26=> next_state <= e27;
      WHEN e27=> IF dpcsvec2(2)='1' THEN Ldacc <= '1'; END IF;
                 next_state <= e28;
      WHEN e28=> dce <= '0';
                 Dracc<='0';
                 addr <= "ZZZZZZZZ";
                 Ldacc <= '0';
                 next_state <= f1;
      WHEN others => null;
    END CASE;
  END PROCESS;

  -- INSTANTIATE INTERNAL COMPONENTS
  pcu : pcunit PORT MAP (pc,"00000000",pcsel,ldnewpc,rst);
END one;




LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY tb_mbctl IS
END tb_mbctl;

ARCHITECTURE one OF tb_mbctl IS

COMPONENT clkdrv IS
  PORT(mclk : OUT std_logic;
       clk  : OUT std_logic);
END COMPONENT;
FOR ALL: clkdrv USE ENTITY WORK.clkdrv(one);

COMPONENT mbctl IS
  PORT(stld : OUT std_logic;
       ldcmpl : IN std_logic;
       Dbus : IN std_logic_vector(7 downto 0);
       addr : OUT std_logic_vector(7 downto 0);
       rst : IN std_logic;
       clk,mclk : IN std_logic;
       rw,ice : OUT std_logic;
       dce : OUT std_logic;
       Aal,Bbu,Bmltch,Ldacc,Dracc,AddSub,Arlo : OUT std_logic;
       Csel : OUT std_logic_vector(1 downto 0);
       Funct : OUT std_logic_vector(3 downto 0);
       C,N,Z : IN std_logic;
       CtlCout : OUT std_logic);
END COMPONENT;
FOR ALL: mbctl USE ENTITY WORK.mbctl(one);

SIGNAL stld, ldcmpl, rst, clk, mclk, rw, ice, dce, Aal, Bbu, Bmltch, Ldacc, Dracc, AddSub, Arlo, C, N, Z, CtlCout: std_logic;
SIGNAL Dbus, addr: std_logic_vector(7 downto 0);
SIGNAL Csel: std_logic_vector(1 downto 0);
SIGNAL Funct: std_logic_vector(3 downto 0);

BEGIN
ptmp: clkdrv PORT MAP (mclk, clk);
ptmp2: mbctl PORT MAP (stld, ldcmpl, Dbus, addr, rst, clk, mclk, rw, ice, dce, Aal, Bbu, Bmltch, Ldacc, Dracc, AddSub, Arlo, Csel, Funct, C,N,Z, CtlCout);

PROCESS
BEGIN
    
-- LDA Immediate
rst <= '0';
ldcmpl <= '1';
wait for 10 ns;

rst <= '1'; 
Dbus <= "10000001", "11111111" after 50 ns; 
C <= '0'; 
N <= '0';
Z <= '0';
wait for 90 ns;

-- LDA Direct
rst <= '1'; 
Dbus <= "10000010", "11111111" after 40 ns; 
C <= '0'; 
N <= '0';
Z <= '0';
wait for 120 ns;

-- STA Direct
rst <= '1'; 
Dbus <= "10100010", "11111111" after 40 ns; 
C <= '0'; 
N <= '0';
Z <= '0';
wait for 120 ns;

-- Add Immediate
rst <= '1'; 
Dbus <= "01000001", "11111111" after 40 ns; 
C <= '0'; 
N <= '0';
Z <= '0';
wait for 80 ns;

-- Add with Carry Immediate
rst <= '1'; 
Dbus <= "01001001", "11111111" after 40 ns; 
C <= '0'; 
N <= '0';
Z <= '0';
wait for 80 ns;

-- Add Direct
rst <= '1'; 
Dbus <= "01000010", "11111111" after 40 ns; 
C <= '0'; 
N <= '0';
Z <= '0';
wait for 120 ns;

-- Subtract Immediate
rst <= '1'; 
Dbus <= "01010001", "11111111" after 40 ns; 
C <= '0'; 
N <= '0';
Z <= '0';
wait for 80 ns;

-- Subtract Immediate minus Carry
rst <= '1'; 
Dbus <= "01110001", "11111111" after 40 ns; 
C <= '0'; 
N <= '0';
Z <= '0';
wait for 80 ns;

-- AND Immediate
rst <= '1'; 
Dbus <= "01011001", "11111111" after 40 ns; 
C <= '0'; 
N <= '0';
Z <= '0';
wait for 80 ns;


-- OR Immediate
rst <= '1'; 
Dbus <= "01011101", "11111111" after 40 ns; 
C <= '0'; 
N <= '0';
Z <= '0';
wait for 80 ns;

-- XOR Immediate
rst <= '1'; 
Dbus <= "01010101", "11111111" after 40 ns; 
C <= '0'; 
N <= '0';
Z <= '0';
wait for 80 ns; 

-- CLRC Inherent 
rst <= '1'; 
Dbus <= "01000000", "11111111" after 40 ns; 
C <= '0'; 
N <= '0';
Z <= '0';
wait for 80 ns;

--- CSET Inherent
rst <= '1'; 
Dbus <= "01001000", "11111111" after 40 ns; 
C <= '0'; 
N <= '0';
Z <= '0';
wait for 80 ns;
wait;
END PROCESS;
END one;
