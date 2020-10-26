with Ada.Text_IO;
with Ada.Exceptions;

package body SoE is

   --  slow down factor for the activity of process Odd
   Slow_Down_Factor : constant Duration := 1.0;

   --  each process instance gets an own Id
   Assigned_Id : Natural := 0;

   --  function specification
   ----------------------------------------
   function Get_Id return Positive;
   function New_Sieve (Val : Positive) return Sieve_Ref;

   --  this is the procedure that will be called upon the finalization
   --  of any scope that contains objects of type Last_Wishes
   ----------------------------------------
   procedure Finalize (Last_Wishes : in out Last_Wishes_T) is
      use Ada.Text_IO;
   begin
      Put_Line ("Process " &
                Natural'Image (Last_Wishes.Id) &
                " has completed and can terminate");
   end Finalize;

   --+-------------------------------------
   task body Odd is
      --  process Odd has a child process Sieve (instance of Sieve_T)
      --  with which it will rendezvous for passing down the numbers
      --  to search for primes in
      Sieve       : Sieve_Ref;
      Num        : Positive  := 3;
      Limit       : Positive;
      --  Odd gets the first Id
      Last_Wishes : Last_Wishes_T :=
        Last_Wishes_T'(Ada.Finalization.Limited_Controlled with Id => Get_Id);
   begin
      accept Set_Limit (User_Limit : Positive) do
         Limit := User_Limit;
      end Set_Limit;
      --  Odd creates its successor and sends it the prime to guard
      Sieve := New_Sieve (Num);
      Num := Num + 2;
      while Num < Limit loop
         --  process Odd passes down to Sieve by rendez-vous
         --  all odd numbers subsequent to 3 in the range to Limit
         --  (the 1st number passed down the line
         --   is known to be a prime)
         Sieve.Relay (Num);
         Num := Num + 2;
         delay Slow_Down_Factor;
      end loop;
      Ada.Text_IO.Put_Line ("Odd ready to finalize ...");
      --  process Odd completes ...
   end Odd;

   ----------------------------------------
   task body Sieve_T is
      use Ada.Text_IO;
      Sieve  : Sieve_Ref;
      Prime,
      Num    : Positive;
      --  any process instance of Sieve_T will possess a finalizable object,
      --  initialized to the process id of that particular instance, so that
      --  its termination will be trapped by the finalization of the object
      Last_Wishes : Last_Wishes_T :=
        Last_Wishes_T'(Ada.Finalization.Limited_Controlled with Id);
   begin
      --  any instance of Sieve_T accepts the 1st rendezvous
      --  with its master, knowing that the 1st incoming value
      --  will be a prime
      accept Relay (Int : Positive) do
         Prime := Int;
      end Relay;
      Put_Line ("Sieve instance " & Natural'Image (Id) &
                " found prime number" & Natural'Image (Prime));
      loop
         --  the instace of Sieve_T continues to accept rendezvous
         --  with its master to receive all other odd numbers
         --  in the designated range
         --
         --  as we cannot be sure that there will always
         --  be callers on this entry (the corresponding master
         --  or parent may have completed in the meanwhile)
         --  we should protect this process from infinite wait
         --  and allow it to terminate in case no partner
         --  was alive anymore
         select
            accept Relay (Int : Positive) do
               Num := Int;
            end Relay;
         or
            --  this alternative will allow the process instance
            --  to abandon the select statement in case
            --  no partner there were no partner left to synchronise with
            terminate;
         end select;
         exit when Num rem Prime /= 0;
      end loop;
      --  any number which is not divisible by Prime
      --  is itself a new prime, and we must pass it on
      --  by rendezvous to a new child process, instance
      --  of Sieve, so that it can continue the search
      Sieve := New_Sieve (Num);
      loop
         --  at this point Sieve can accept from its master
         --  all the remaining odd numbers in the range and
         --  pass down to its child Sieve those that are
         --  candidate primes because they are not divisible
         --  by Prime
         --
         --  we must do the same as before of course
         select
            accept Relay (Int : Positive) do
               Num := Int;
            end Relay;
         or
            --  again, we need to place a terminate alternative
            --  to allow the accepter to leave the select
            terminate;
         end select;
         if Num rem Prime /= 0 then
            Sieve.Relay (Num);
         end if;
      end loop;
      --  process Sieve will complete when all select constructs
      --  will be terminated for the lack of partners
   exception
      when E : others =>
         Put_Line ("Exception "
                   & Ada.Exceptions.Exception_Name (E)
                   & " propagated to Sieve instance " & Positive'Image (Id));
         Flush;
   end Sieve_T;

   ---------------------------------------------------------------------------
   --  function body
   ----------------------------------------
   function Get_Id return Positive is
   begin
      Assigned_Id := Assigned_Id + 1;
      return Assigned_Id;
   end Get_Id;

   function New_Sieve (Val : Positive) return Sieve_Ref is
   begin
      --  we want to create a new instance of Sieve
      --  that is immediately sent the prime to guard
      --  to this end we use the "extended return" construct
      return Result : Sieve_Ref := new Sieve_T (Get_Id) do
         Result.Relay (Val);
      end return;
   end New_Sieve;

end SoE;
