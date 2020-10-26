with System;
with SoE;
with Ada.Text_IO, Ada.Integer_Text_IO;
with Ada.Exceptions;

procedure Main is
   use Ada.Text_IO, Ada.Integer_Text_IO;
   pragma Priority (System.Priority'First);
   User_Limit : Integer;
begin
   --  process Odd is activated at this point
   --+
   --  the main unit may take the range limit from user input
   --  and pass it on, by rendezvous, to Odd
   Put ("Insert range limit: ");
   Get (User_Limit);
   SoE.Odd.Set_Limit (User_Limit);
   --  at this point the main unit has nothing other to do
   --  than wait for its dependent processes (Odd and all instances of Sieve)
   --  to terminate
exception
   when E : others =>
      Put_Line ("Exception "
                & Ada.Exceptions.Exception_Name (E));
end Main;
