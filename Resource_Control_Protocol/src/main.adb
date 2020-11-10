with RCP;
with RCP.Control;
with RCP.User;
procedure Main is
   use RCP, RCP.Control, RCP.User;

   --  user 1 needs 3 resources and "uses them" 8 seconds at a time
   One   : User_T (1, Short, 3, 8);
   --  user 2 needs 2 resources and "uses them" 12 seconds at a time
   Two   : User_T (2, Short, 2, 12);
   --  user 3 needs 4 resources and "uses them" 16 seconds at a time
   Three : User_T (3, Medium, 4, 16);
   --  user 4 needs 1 resource and "uses them" 20 seconds at a time
   Four  : User_T (4, Medium, 1, 20);
   --  user 5 needs 5 resources and "uses them" 24 seconds at a time
   Five  : User_T (5, Long, 5, 24);
   --  user 6 needs 6 resources and "uses them" 28 seconds at a time
   Six   : User_T (6, Long, 6, 28);

begin
   null;
end Main;
