    module ExtractTimeModule
    
    contains
    
    ! レポートから時間を抽出する
    subroutine ExtractTimeFromReport(input, output)
        use FileDataModule
        implicit none
        character(256), intent(in) :: input, output
        
        type(FileData) file
        integer i, header_count
        
        file = init_FileData(20, input)
        
        ! ヘッダの数を数える
        header_count = 0
        do i = 1, file%numof_lines
            if (INDEX(file%lines(i), "  X  ") > 0) then
                header_count = header_count + 1
            end if
        end do
        
        
        CALL final_FileData(file)
    end subroutine
    
    end module