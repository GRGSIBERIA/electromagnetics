    module ExtractDisplacementModule
    
	contains
    
	! ヘッダの数を数える関数
	integer function HeaderCountX(file) result(count)
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
    
    ! ヘッダから情報を抽出する
    subroutine ExtractInformationFromHeader(header, axisid, nodeid)
        character(256), intent(in) :: header
        integer, intent(out) :: axisid, nodeid
        
        character(16) axis
        integer temp
        READ (header(4:4), *) axisid
        
        temp = INDEX(header, ":", back=.TRUE.) + 1
        READ (header(temp+1:), *) nodeid
        
    end subroutine
	
    ! ヘッダを生成する関数
	function GenerateHeader(file, header_count, header_position) result(headers)
		use FileDataModule
		implicit none
		type(FileData), intent(in) :: file
		integer, intent(in) :: header_count
        integer, dimension(header_count), intent(out) :: header_position
		
		character(256), dimension(header_count) :: headers
        character(256) header
		integer i, pos, tmp, count
		
		count = 1
		do i = 1, file%numof_lines
			pos = INDEX(file%lines(i), "  X  ")
			if (pos > 0) then
                header_position(count) = i + 2
                
                ! 後ろに戻りながら空白行が見つかるまでヘッダを作り続ける
                header = file%lines(i)
                header = adjustl(header(pos+5:))
				tmp = i - 1
				do
					if (len_trim(adjustl(file%lines(tmp))) <= 0) then
						goto 100
					end if
					
					header = trim(adjustl(file%lines(tmp))) // header
                    tmp = tmp - 1
				end do
100             continue
                headers(count) = header
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
        integer, dimension(:), allocatable :: nodeids, axisids
        
		CALL Exists(input)
        fd = ScanValidFD(20)
		file = init_FileData(fd, input)
		
		header_count = HeaderCountX(file)
        ALLOCATE (header_positions(header_count))
		headers = GenerateHeader(file, header_count, header_positions)
		
        ALLOCATE (nodeids(size(headers)))
        ALLOCATE (axisids(size(headers)))
        
        !$omp parallel
        !$omp do
        do i = 1, size(headers)
            CALL ExtractInformationFromHeader(headers(i), axisids(i), nodeids(i))
        end do
        !$omp end do
        !$omp end parallel
        
        PRINT *, "MAX NODE ID:", MAXVAL(nodeids(:))
        
        DEALLOCATE (headers)
        DEALLOCATE (header_positions)
        DEALLOCATE (nodeids)
        DEALLOCATE (axisids)
    end subroutine
    
    end module