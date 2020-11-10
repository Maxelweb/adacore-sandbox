with Ada.Text_IO;
with RCP.Control;

package body RCP.User is

   task body User_T is
      use Ada.Text_IO, RCP.Control;
      --  all users will want the same type of item
      --  but in different quantities
      --  (note that the object components will take their default value
      --   unless overridden by the instantiation)
      My_Allocation : Resource_T :=
        Resource_T'(Item => Extent, Granted => Request_T'First);
   begin
      loop
         Put_Line (" " & Positive'Image (Id)
                   & "  |   "
                   & Request_T'Image (Demand)
                   & "    |            |");
         --------------------------------------------------------
         --  a user requests the allocation of "demand" resources
         Controller.Demand (My_Allocation, Demand);
         --------------------------------------------------------
         Put_Line (" " & Positive'Image (Id)
                   & "  |         |    "
                   & Request_T'Image (My_Allocation.Granted)
                   & "      |");
         --------------------------------------------------------
         --  fakes some work once the request has been satisfied
         delay Duration (Interval);

         --  then returns all of the resources in its possession
         Controller.Release (My_Allocation);
         --------------------------------------------------------
         Put_Line (" " & Positive'Image (Id)
                   & "  |         |            |   "
                   & Request_T'Image (My_Allocation.Granted));

         --  and finally happily rests a little while after a job well done
         delay Duration (Interval);
      end loop;
   end User_T;

end RCP.User;
