LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY mbalu IS
   PORT(A,B : IN std_logic_vector(7 downto 0);
        res : OUT std_logic_vector(7 downto 0);
        cin : IN std_logic;
        Fun : IN std_logic_vector(3 downto 0);
        Csel : IN std_logic_vector(1 downto 0);
        Arlo : IN std_logic;
        AddSub : IN std_logic;
        Cout,N,Z : OUT std_logic);
END mbalu;

ARCHITECTURE one OF mbalu IS
   SIGNAL Lout,ires : std_logic_vector(7 downto 0);
   SIGNAL Binv,Binp,Sum : std_logic_vector(7 downto 0);
   SIGNAL Cs1,Cc1,Cval,Cinp : std_logic;
   SIGNAL Ctemp : std_logic_vector(8 downto 0);
   SIGNAL iFun0,iFun1,iFun2,iFun3 : std_logic_vector(7 downto 0);
   
BEGIN
-- Set up the 8 bits for the function select'
iFun0 <= Fun(0) & Fun(0) & Fun(0) & Fun(0) & Fun(0) & Fun(0) & Fun(0) & Fun(0);
iFun1 <= Fun(1) & Fun(1) & Fun(1) & Fun(1) & Fun(1) & Fun(1) & Fun(1) & Fun(1);
iFun2 <= Fun(2) & Fun(2) & Fun(2) & Fun(2) & Fun(2) & Fun(2) & Fun(2) & Fun(2);
iFun3 <= Fun(3) & Fun(3) & Fun(3) & Fun(3) & Fun(3) & Fun(3) & Fun(3) & Fun(3);
-- Logic Unit  
Lout <= (NOT A AND NOT B AND iFun0) OR (NOT A AND B AND iFun1) OR (A AND NOT B AND iFun2) OR (A AND B AND iFun3);

-- Prep B input to Add/Sub
Binv <= NOT B;
Binp <= B WHEN AddSub = '1' ELSE Binv;

Cs1 <= Cin WHEN Csel(0)='0' ELSE NOT Cin;
Cc1 <= '0' WHEN Csel(0)='0' ELSE '1';
Cinp <= Cs1 WHEN Csel(1)='0' ElSE Cc1;
Ctemp(0) <= Cinp;

-- add 2 inputs
Ctemp(8 downto 1) <= (A AND Binp) OR (A AND Ctemp(7 downto 0)) OR (B AND Ctemp(7 downto 0));
Sum <= A XOR Binp XOR Ctemp(7 downto 0);

-- generate outputs
Cout <= Ctemp(8);
N <= ires(7);
Z <= NOT(ires(7) OR ires(6) OR ires(5) OR ires(4) OR ires(3) OR ires(2) OR ires(1) OR ires(0));

ires <= Sum WHEN Arlo = '1' ELSE Lout;
res <= ires;
 
END one;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY tb_mbalu IS
END tb_mbalu;

ARCHITECTURE one OF tb_mbalu IS

SIGNAL A, B, RES: std_logic_vector(7 downto 0);
SIGNAL cin, Arlo, AddSub, Cout, N, Z: std_logic;
SIGNAL Fun: std_logic_vector(3 downto 0);
SIGNAL Csel: std_logic_vector (1 downto 0);
SIGNAL ERROR: std_logic;

COMPONENT mbalu IS
   PORT(A,B : IN std_logic_vector(7 downto 0);
        res : OUT std_logic_vector(7 downto 0);
        cin : IN std_logic;
        Fun : IN std_logic_vector(3 downto 0);
        Csel : IN std_logic_vector(1 downto 0);
        Arlo : IN std_logic;
        AddSub : IN std_logic;
        Cout,N,Z : OUT std_logic);
END COMPONENT;
FOR ALL: mbalu USE ENTITY WORK.mbalu(one);



BEGIN
ptmp: mbalu PORT MAP (A,B, res, cin, Fun, Csel, Arlo, AddSub, Cout, N, Z);

PROCESS
BEGIN

-- Add/Sub Functionality
Arlo <= '1'; Cin <= '0'; Csel <= "00";
AddSub <= '1';--Add Function	
A <= "00001001"; 
B <= "00100010";
WAIT FOR 100 ns;


A <= "10001001"; 
B <= "00110010";
WAIT FOR 100 ns;

A <= "11111111"; 
B <= "00000001";
WAIT FOR 100 ns;

A <= "10000001"; 
B <= "11111111";
WAIT FOR 100 ns;

A <= "00000000"; 
B <= "00000000";
WAIT FOR 100 ns;

AddSub <= '0';--Sub Function
A <= "11111101"; 
B <= "11111110";
Csel <="11";
WAIT FOR 100 ns;

A <= "11111111"; 
B <= "00000001";
WAIT FOR 100 ns;

Cin <= '1'; AddSub <= '1';--Add with carry
Csel <= "00";
A <= "00000000"; 
B <= "00000101";
WAIT FOR 100 ns;

Csel <= "01";--Add with invert carry
WAIT FOR 100 ns;

Csel <= "10";--Add with cin='0'
WAIT FOR 100 ns;

Csel <= "11";--Add with cin='1'
WAIT FOR 100 ns;

-- Logic Functionality
Csel <= "00";
Arlo <= '0'; Fun <= "1000";-- AND
A <= "10100011"; 
B <= "11000101";
WAIT FOR 100 ns;

Fun <= "1110";--OR
WAIT FOR 100 ns;

Fun <= "0011";--INV
WAIT FOR 100 ns;

Fun <= "0110";--XOR
WAIT FOR 100 ns;

WAIT;
END PROCESS;

END one;