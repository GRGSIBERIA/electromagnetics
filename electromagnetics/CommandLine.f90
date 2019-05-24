    module CommandLine
    
    implicit none
    
    contains
    
    function GetCommandLine(test) result(commands)
        implicit none
        character(256), dimension(:), allocatable :: commands
        integer, intent(in) :: test
        
        integer i, length, status
        
        if (test /= 0) then
            
        else
            ALLOCATE (commands(COMMAND_ARGUMENT_COUNT() + 1))
            
            do i = 0, COMMAND_ARGUMENT_COUNT()
                CALL GET_COMMAND_ARGUMENT(i, length = length, status = status)
                if (status /= 0) then
                    goto 200
                end if
                
                CALL GET_COMMAND_ARGUMENT(i, commands(i+1), status = status)
                if (status /= 0) then
                    goto 200
                end if
                
            end do
            
        end if
        goto 100
        
200     continue
        PRINT *, "ERROR: ", status, "on argument", i
        STOP
        
100     continue        
        
    end function
    
    end module