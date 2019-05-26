    module ExtractDisplacementModule
    
	contains
    
	! ヘッダの数を数える関数
	integer function HeaderCountX(file, header_position) result(count)
		use FileDataModule
		implicit none
		type(FileData), intent(in) :: file
		integer i
		count = 0
		
		do i = 1, file%numof_lines
			if (INDEX(file%lines(i), "  X  ") > 0) then
				count = count + 1
			end if
		end do
    end function
	
    ! ヘッダを生成する関数
	function GenerateHeader(file, header_count, header_position) result(headers)
		use FileDataModule
		implicit none
		type(FileData), intent(in) :: file
		integer, intent(in) :: header_count
        integer, dimension(header_count), intent(out) :: header_position
		
		character(256), dimension(header_count) :: headers
		integer i, pos, tmp, count
		
		count = 1
		do i = 1, file%numof_lines
			pos = INDEX(file%lines(i), "  X  ")
			if (pos > 0) then
                header_position(count) = i + 2
                
                ! 後ろに戻りながら空白行が見つかるまでヘッダを作り続ける
				headers(count) = adjustl(file%lines(i)(pos:))
				tmp = i - 1
				do
					if (len_trim(adjustl(file%lines(tmp))) <= 0) then
						goto 100
					end if
					
					headers(count) = adjustl(trim(file%lines(tmp))) // headers(count)
                    tmp = tmp - 1
				end do
100             continue
                count = count + 1
			end if
		end do
	end function
	
    ! レポートから変位を抽出する
    subroutine ExtractDisplacementFromReport(input, output)
		use FileDataModule
		use FileUtil
        implicit none
        character(256), intent(in) :: input, output
		
		integer fd, i, header_count
		type(FileData) file
		character(256), dimension(:), allocatable :: headers
        integer, dimension(:), allocatable :: header_positions
		
		CALL Exists(input)
        fd = ScanValidFD(20)
		file = init_FileData(fd, input)
		
		header_count = HeaderCountX(file)
		headers = GenerateHeader(file, header_count, header_positions)
		
    end subroutine
    
    end module