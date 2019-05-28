    module ExtractTimeModule
    
	contains
    
	subroutine ReadReportFile(inputfd, outputfd)
		implicit none
		integer, intent(in) :: inputfd, outputfd
		
		character(256) line
		double precision :: time, value
		
		! Xがあると次の次の行で数値列が来る
		do
			READ (inputfd, "(A)") line
			if (INDEX(line, "  X  ") > 0) then
				READ (inputfd, "(A)") line
				goto 200
			end if
		end do
200		continue		
		
		! 数値データの読み込み，改行のみが来たら抜ける
		do
			READ (inputfd, "(A)") line
			if (len_trim(line) < 1) then
				goto 300
			end if
			
			! 書式指定だと正確に読み込まないので自由書式にする
			READ (line, *) time, value
			WRITE (outputfd, *) time
		end do
300		continue		
		
	end subroutine
	
    ! レポートから時間を抽出する
    subroutine ExtractTimeFromReport(input, output)
		use FileUtil
        implicit none
        character(256), intent(in) :: input, output
        
        integer i, header_count, inputfd, outputfd, logic
        
		! 有効なFDをチェックする
		inputfd = ScanValidFD(20)
		outputfd = ScanValidFD(inputfd + 1)
        
		! ファイルの存在をチェックした後にファイルを開く
		CALL Exists(input)
		
		OPEN (inputfd, file=input, status="old")
		OPEN (outputfd, file=output, status="replace")
		
		PRINT *, "Reading a report file."
		CALL ReadReportFile(inputfd, outputfd)
		PRINT *, "Extracted a report file into an output."
		
		CLOSE (inputfd)
		CLOSE (outputfd)
		
    end subroutine
    
    end module