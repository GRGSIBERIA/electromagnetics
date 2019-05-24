    module ConfigureFileModule
    implicit none
    
    ! 入力ファイル用の構造体
    type InputFile
        ! inputはジオメトリの情報
        ! reportは入力する時刻歴データの情報
        integer :: input_fd, report_fd
    end type
    
    ! 設定ファイルの構造体
    type ConfigureFile
        integer :: output_fd
        integer :: time_fd
        
        integer :: numof_parts, numof_coils
        type(InputFile), dimension(:), allocatable :: parts, tops, bottoms
    end type
    
    contains
    
    ! 入力ファイルを閉じる処理
    subroutine final_InputFile(file)
        implicit none
        type(InputFile) file
        CLOSE (file%input_fd)
        CLOSE (file%report_fd)
    end subroutine
    
    ! InputFile構造体の初期化
    type(InputFile) function init_InputFile(nowfd, inputpath, reportpath) result(file)
        implicit none
        integer, intent(inout) :: nowfd
        character(256), intent(in) :: inputpath, reportpath
        
        CALL ReadAsOpen(inputpath, nowfd, file%input_fd, "old")
        CALL ReadAsOpen(reportpath, nowfd, file%report_fd, "old")
    end function
    
    ! ファイルを読み込んでから，ファイルを開く処理を行う
    subroutine ReadAsOpen(line, nowfd, fd, status)
        use FileUtil
        implicit none
        character(*), intent(in) :: line
        integer, intent(inout) :: nowfd
        integer, intent(out) :: fd
        character(*), intent(in) :: status
        
        character(256) path
        
        READ (line, "(A)") path
        
        ! oldの場合，ファイルが存在するかチェックする
        if (INDEX(status, "old") > 0) then
            CALL Exists(path)
        end if
        
        fd = nowfd
        OPEN (nowfd, file=path, status=status, blocksize=1024, buffercount=1024)
        nowfd = nowfd + 1
        
    end subroutine
    
    type(ConfigureFile) function init_ConfigureFile(fd, path, startfd) result(config)
        use FileDataModule
        implicit none
        
        integer, intent(in) :: fd, startfd
        character(*), intent(in) :: path
        
        type(FileData) file
        character(256) :: inputpath, reportpath
        integer i, count, nowfd, part_count, coil_count
        
        nowfd = startfd
        file = init_FileData(fd, path)
        config%numof_parts = 0
        config%numof_coils = 0
        part_count = 0
        coil_count = 0
        
        ! ファイルの数などを数える
        do i = 1, file%numof_lines
            if (INDEX(file%lines(i), "*InputFile") > 0) then
                config%numof_parts = config%numof_parts + 1
            else if (INDEX(file%lines(i), "*CoilFile") > 0) then
                config%numof_coils = config%numof_coils + 1
            end if
        end do
        
        ALLOCATE(config%parts(config%numof_parts))
        ALLOCATE(config%tops(config%numof_coils))
        ALLOCATE(config%bottoms(config%numof_coils))
        
        ! 実際に設定を読み込む
        count = 1
        do
            if (count > file%numof_lines) then
                goto 100
            end if
            
            if (INDEX(file%lines(count), "*OutputFile") > 0) then
                ! *OutputFile (1つだけ定義，複数存在する場合は後続の定義に置換)
                ! 出力ファイルへのパス
                count = count + 1
                CALL ReadAsOpen(file%lines(count), nowfd, config%output_fd, "replace")
                
            else if (INDEX(file%lines(count), "*InputFile") > 0) then
                ! *InputFile (複数定義可能)
                ! 節点座標のパス
                ! レポートのパス
                
                ! 磁化するパートの読み込み
                part_count = part_count + 1
                config%parts(part_count) = init_InputFile(nowfd, file%lines(count + 1), file%lines(count + 2))
                count = count + 2
                
            else if (INDEX(file%lines(count), "*CoilFile") > 0) then
                ! *CoilFile (複数定義可能)
                ! topの節点座標のパス
                ! topのレポートのパス
                ! bottomの節点座標のパス
                ! bottomのレポートのパス
                coil_count = coil_count + 1
                
                ! コイル上面, 底面の読み込み
                config%tops(coil_count) = init_InputFile(nowfd, file%lines(count + 1), file%lines(count + 2))
                config%bottoms(coil_count) = init_InputFile(nowfd, file%lines(count + 3), file%lines(count + 4))
                count = count + 4
                
            else if (INDEX(file%lines(count), "*TimeFile") > 0) then
                ! *TimeFile(1つだけ定義可能)
                ! 時刻歴定義ファイルのパス
                count = count + 1
                CALL ReadAsOpen(file%lines(count), nowfd, config%time_fd, "old")
                
            end if
            
            count = count + 1
        end do
100     continue    
    
    end function
    
    ! 設定ファイルの終了処理
    subroutine final_ConfigureFile(config)
        implicit none
        type(ConfigureFile) config
        integer i
        
        CLOSE (config%output_fd)
        CLOSE (config%time_fd)
        
        do i = 0, config%numof_parts
            CALL final_InputFile(config%parts(i))
        end do
        
        do i = 0, config%numof_coils
            CALL final_InputFile(config%tops(i))
            CALL final_InputFile(config%bottoms(i))
        end do
        
        DEALLOCATE (config%parts)
        DEALLOCATE (config%tops)
        DEALLOCATE (config%bottoms)
    end subroutine
    
    end module