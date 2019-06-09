﻿    module CommandInterpreter
    implicit none
    
    contains
    
    ! 単なるヘルプの表示
    subroutine PrintHelp()
        implicit none
        
        PRINT *, "Usage: cem.exe [command] [<arguments>]"
        PRINT *, "Attension: Execute only the first command."
        PRINT *, "Commands:"
        PRINT *, "-h"
		PRINT *, "    ", "See help."
        PRINT *, "-a [config file]"
        PRINT *, "    ", "Analyzes electromagnetics to use a configuration file"
        PRINT *, "-t [input report] [output file]"
		PRINT *, "    ", "Extracts times from an abaqus report file."
        PRINT *, "-r [.inp file] [input report] [output file]"
		PRINT *, "    ", "Extracts displacements from an abaqus report file."
    end subroutine
    
    subroutine StartCommandInterpreter(commands)
        use ExtractTimeModule
        use ExtractDisplacementModule
        use AnalyzeModule
        
        implicit none
        character(256), dimension(:), intent(in) :: commands
        
        integer i
        i = 2
        
        ! コマンドライン引数がないときはヘルプを表示する
        if (size(commands) < 2) then
            goto 200
        end if
        
        do
            if (INDEX(commands(i), "-t") > 0) then
                ! レポートから時間を抽出する
                ! -t <入力レポート> <出力ファイル>
                if (size(commands) < 4) then
                    PRINT *, "ERROR: Insufficient arguments"
                    goto 200    ! 引数がエラってる
                end if
                CALL ExtractTimeFromReport(commands(i+1), commands(i+2))
                goto 100
                
            else if (INDEX(commands(i), "-r") > 0) then
                ! レポートから変位を抽出する
                ! -r <パート定義> <入力レポート> <出力ファイル>
                if (size(commands) < 5) then
                    PRINT *, "ERROR: Insufficient arguments"
                    goto 200
                end if
                CALL ExtractDisplacementFromReport(commands(i+1), commands(i+2), commands(i+3))
                goto 100
                
            else if (INDEX(commands(i), "-a") > 0) then
                ! 解析を行う
                ! -r <設定ファイル>
                if (size(commands) < 3) then
                    PRINT *, "ERROR: Insufficient arguments"
                    goto 200
                end if
                CALL AnalyzeElectromagnetics(commands(i+1))
                goto 100
                
            else if (INDEX(commands(i), "-h") > 0) then
                ! ヘルプを表示してプログラムを止める
                goto 200
                
            end if
            
            i = i + 1
        end do
200     continue
        CALL PrintHelp()
        STOP
        
100     continue
        
    end subroutine
    
    end module