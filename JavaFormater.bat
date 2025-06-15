/*
 * MIT License
 *
 * Copyright (c) {2025} {jmfrohs}
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

@echo off
setlocal EnableDelayedExpansion

:: Java Code Formatter Batch Script
:: Verwendet Google Java Format für automatische Code-Formatierung

echo ===============================================
echo        Java Code Formatter
echo ===============================================
echo.

:: Konfiguration
set "FORMATTER_JAR=google-java-format-1.19.2-all-deps.jar"
set "FORMATTER_URL=https://github.com/google/google-java-format/releases/download/v1.19.2/google-java-format-1.19.2-all-deps.jar"
set "JAVA_FILES_PATTERN=*.java"
set "TXT_FILES_PATTERN=*.txt"
set "BACKUP_SUFFIX=.backup"
set "CONFIG_FILE=formatter_config.ini"
set "LOG_FILE=formatter_log.txt"
set "LICENSE_FILE=license_templates.txt"

:: Lade Konfiguration
call :load_config

:: Prüfe ob Java installiert ist
java -version >nul 2>&1
if errorlevel 1 (
    echo FEHLER: Java ist nicht installiert oder nicht im PATH verfügbar!
    echo Bitte installieren Sie Java und fügen Sie es zum PATH hinzu.
    pause
    exit /b 1
)

:: Prüfe ob Google Java Format JAR existiert
if not exist "%FORMATTER_JAR%" (
    echo Google Java Format JAR nicht gefunden.
    echo Lade %FORMATTER_JAR% herunter...
    echo.
    
    :: Versuche Download mit PowerShell
    powershell -Command "try { Invoke-WebRequest -Uri '%FORMATTER_URL%' -OutFile '%FORMATTER_JAR%' -UseBasicParsing } catch { exit 1 }"
    
    if errorlevel 1 (
        echo FEHLER: Download fehlgeschlagen!
        echo Bitte laden Sie die JAR-Datei manuell herunter:
        echo %FORMATTER_URL%
        echo und speichern Sie sie als "%FORMATTER_JAR%" in diesem Ordner.
        pause
        exit /b 1
    )
    
    echo Download erfolgreich!
    echo.
)

:: Zeige verfügbare Optionen
echo Verfügbare Modi:
echo [1] Aktuelles Verzeichnis formatieren (.java Dateien)
echo [2] Spezifisches Verzeichnis formatieren (.java Dateien)
echo [3] Einzelne Datei formatieren (.java oder .txt)
echo [4] Rekursiv alle Unterordner formatieren (.java Dateien)
echo [5] TXT-Datei mit Java-Code formatieren
echo [6] Alle TXT-Dateien in Verzeichnis formatieren
echo [7] Drag ^& Drop Modus (Dateien hierauf ziehen)
echo [8] Code-Validierung ohne Formatierung
echo [9] Einstellungen konfigurieren
echo [A] Backup-Dateien aufräumen
echo [B] Formatierungs-Log anzeigen
echo [C] Code-Statistiken anzeigen
echo [D] Lizenz-Header hinzufügen
echo [E] Lizenz-Vorlagen verwalten
echo [F] Formatieren + Lizenz hinzufügen
echo [0] Beenden
echo.

set /p "choice=Wählen Sie eine Option (0-9, A-F): "

if "%choice%"=="0" goto :end
if "%choice%"=="1" goto :format_current
if "%choice%"=="2" goto :format_specific
if "%choice%"=="3" goto :format_single
if "%choice%"=="4" goto :format_recursive
if "%choice%"=="5" goto :format_txt_file
if "%choice%"=="6" goto :format_txt_directory
if /i "%choice%"=="7" goto :drag_drop_mode
if /i "%choice%"=="8" goto :validate_code
if /i "%choice%"=="9" goto :configure_settings
if /i "%choice%"=="A" goto :cleanup_backups
if /i "%choice%"=="B" goto :show_log
if /i "%choice%"=="C" goto :show_statistics
if /i "%choice%"=="D" goto :add_license_headers
if /i "%choice%"=="E" goto :manage_license_templates
if /i "%choice%"=="F" goto :format_and_license

echo Ungültige Auswahl!
goto :end

:format_current
echo.
echo Formatiere Java-Dateien im aktuellen Verzeichnis...
call :format_directory "%cd%"
goto :end

:format_specific
echo.
set /p "target_dir=Geben Sie den Pfad zum Verzeichnis ein: "
if not exist "%target_dir%" (
    echo FEHLER: Verzeichnis existiert nicht!
    goto :end
)
echo Formatiere Java-Dateien in "%target_dir%"...
call :format_directory "%target_dir%"
goto :end

:format_single
echo.
set /p "target_file=Geben Sie den Pfad zur Java-Datei ein: "
if not exist "%target_file%" (
    echo FEHLER: Datei existiert nicht!
    goto :end
)
echo Formatiere "%target_file%"...
call :format_file "%target_file%"
goto :end

:format_recursive
echo.
echo Formatiere Java-Dateien rekursiv in allen Unterordnern...
call :format_recursive_directory "%cd%"
goto :end

:format_txt_file
echo.
set /p "target_file=Geben Sie den Pfad zur TXT-Datei mit Java-Code ein: "
if not exist "%target_file%" (
    echo FEHLER: Datei existiert nicht!
    goto :end
)
echo Formatiere TXT-Datei "%target_file%"...
call :format_txt_as_java "%target_file%"
goto :end

:format_txt_directory
echo.
set /p "target_dir=Geben Sie den Pfad zum Verzeichnis mit TXT-Dateien ein: "
if not exist "%target_dir%" (
    echo FEHLER: Verzeichnis existiert nicht!
    goto :end
)
echo Formatiere TXT-Dateien in "%target_dir%"...
call :format_txt_files_in_directory "%target_dir%"
goto :end

:drag_drop_mode
echo.
echo ===============================================
echo            DRAG ^& DROP MODUS
echo ===============================================
echo Ziehen Sie Java- oder TXT-Dateien auf diese
echo Batch-Datei oder geben Sie den Pfad direkt ein.
echo Drücken Sie Enter ohne Eingabe zum Beenden.
echo.

:drag_drop_loop
set /p "dropped_file=Datei-Pfad (oder Enter zum Beenden): "
if "%dropped_file%"=="" goto :end

:: Entferne Anführungszeichen falls vorhanden
set "dropped_file=%dropped_file:"=%"

if not exist "%dropped_file%" (
    echo FEHLER: Datei existiert nicht!
    goto :drag_drop_loop
)

call :format_file "%dropped_file%"
echo.
goto :drag_drop_loop

:validate_code
echo.
echo ===============================================
echo            CODE-VALIDIERUNG
echo ===============================================
set /p "validate_path=Pfad zur Datei oder zum Verzeichnis: "
if not exist "%validate_path%" (
    echo FEHLER: Pfad existiert nicht!
    goto :end
)
call :validate_java_syntax "%validate_path%"
goto :end

:configure_settings
echo.
echo ===============================================
echo            EINSTELLUNGEN
echo ===============================================
echo Aktuelle Einstellungen:
echo - Backup erstellen: %CREATE_BACKUP%
echo - Logging aktiviert: %ENABLE_LOGGING%
echo - Formatter-Stil: %FORMATTER_STYLE%
echo - Einrückung: %INDENT_SIZE% Leerzeichen
echo - Standard-Lizenz: %DEFAULT_LICENSE%
echo - Autor: %AUTHOR_NAME%
echo - Firma: %COMPANY_NAME%
echo - Jahr automatisch aktualisieren: %AUTO_UPDATE_YEAR%
echo - Lizenz automatisch hinzufügen: %AUTO_ADD_LICENSE%
echo.
echo [1] Backup ein/ausschalten
echo [2] Logging ein/ausschalten  
echo [3] Formatter-Stil ändern (Google/AOSP)
echo [4] Einrückung ändern
echo [5] Standard-Lizenz ändern
echo [6] Autor-Informationen setzen
echo [7] Firmen-Informationen setzen
echo [8] Auto-Jahr-Update ein/aus
echo [9] Auto-Lizenz ein/aus
echo [A] Zurück zum Hauptmenü
echo.
set /p "config_choice=Auswahl: "

if "%config_choice%"=="1" call :toggle_backup
if "%config_choice%"=="2" call :toggle_logging
if "%config_choice%"=="3" call :change_style
if "%config_choice%"=="4" call :change_indent
if "%config_choice%"=="5" call :change_default_license
if "%config_choice%"=="6" call :set_author_info
if "%config_choice%"=="7" call :set_company_info
if "%config_choice%"=="8" call :toggle_auto_year
if "%config_choice%"=="9" call :toggle_auto_license
if /i "%config_choice%"=="A" goto :eof

call :save_config
goto :configure_settings

:cleanup_backups
echo.
echo ===============================================
echo            BACKUP-AUFRÄUMEN
echo ===============================================
call :cleanup_backup_files
goto :end

:show_log
echo.
echo ===============================================
echo            FORMATIERUNGS-LOG
echo ===============================================
if exist "%LOG_FILE%" (
    type "%LOG_FILE%"
) else (
    echo Keine Log-Datei gefunden.
)
echo.
pause
goto :end

:show_statistics
echo.
echo ===============================================
echo            CODE-STATISTIKEN
echo ===============================================
call :calculate_statistics
goto :end

:add_license_headers
echo.
echo ===============================================
echo            LIZENZ-HEADER HINZUFÜGEN
echo ===============================================
call :license_header_menu
goto :end

:manage_license_templates
echo.
echo ===============================================
echo            LIZENZ-VORLAGEN VERWALTEN
echo ===============================================
call :license_template_menu
goto :end

:format_and_license
echo.
echo ===============================================
echo        FORMATIEREN + LIZENZ HINZUFÜGEN
echo ===============================================
set /p "target_path=Pfad zur Datei oder zum Verzeichnis: "
if not exist "%target_path%" (
    echo FEHLER: Pfad existiert nicht!
    goto :end
)

echo Schritt 1: Formatiere Code...
if exist "%target_path%\*" (
    call :format_directory "%target_path%"
) else (
    call :format_file "%target_path%"
)

echo.
echo Schritt 2: Füge Lizenz-Header hinzu...
call :add_license_to_path "%target_path%"
echo Formatierung und Lizenzierung abgeschlossen!
pause
goto :end

:: Funktion: Formatiere alle Java-Dateien in einem Verzeichnis
:format_directory
set "dir_path=%~1"
set "file_count=0"

for %%f in ("%dir_path%\%JAVA_FILES_PATTERN%") do (
    call :format_file "%%f"
    set /a file_count+=1
)

if !file_count! EQU 0 (
    echo Keine Java-Dateien in "%dir_path%" gefunden.
) else (
    echo !file_count! Datei(en) formatiert.
)
goto :eof

:: ==================================================
:: NEUE HILFSFUNKTIONEN
:: ==================================================

:: Funktion: Lade Konfiguration
:load_config
:: Standard-Einstellungen
set "CREATE_BACKUP=true"
set "ENABLE_LOGGING=true"
set "FORMATTER_STYLE=Google"
set "INDENT_SIZE=2"
set "DEFAULT_LICENSE=MIT"
set "AUTHOR_NAME="
set "COMPANY_NAME="
set "AUTO_UPDATE_YEAR=true"
set "AUTO_ADD_LICENSE=true"

if exist "%CONFIG_FILE%" (
    for /f "usebackq tokens=1,2 delims==" %%A in ("%CONFIG_FILE%") do (
        if /i "%%A"=="CREATE_BACKUP" set "CREATE_BACKUP=%%B"
        if /i "%%A"=="ENABLE_LOGGING" set "ENABLE_LOGGING=%%B"
        if /i "%%A"=="FORMATTER_STYLE" set "FORMATTER_STYLE=%%B"
        if /i "%%A"=="INDENT_SIZE" set "INDENT_SIZE=%%B"
        if /i "%%A"=="DEFAULT_LICENSE" set "DEFAULT_LICENSE=%%B"
        if /i "%%A"=="AUTHOR_NAME" set "AUTHOR_NAME=%%B"
        if /i "%%A"=="COMPANY_NAME" set "COMPANY_NAME=%%B"
        if /i "%%A"=="AUTO_UPDATE_YEAR" set "AUTO_UPDATE_YEAR=%%B"
        if /i "%%A"=="AUTO_ADD_LICENSE" set "AUTO_ADD_LICENSE=%%B"
    )
)

:: Erstelle Standard-Lizenzvorlagen falls nicht vorhanden
if not exist "%LICENSE_FILE%" call :create_default_licenses

goto :eof

:: Funktion: Speichere Konfiguration  
:save_config
(
    echo CREATE_BACKUP=%CREATE_BACKUP%
    echo ENABLE_LOGGING=%ENABLE_LOGGING%
    echo FORMATTER_STYLE=%FORMATTER_STYLE%
    echo INDENT_SIZE=%INDENT_SIZE%
    echo DEFAULT_LICENSE=%DEFAULT_LICENSE%
    echo AUTHOR_NAME=%AUTHOR_NAME%
    echo COMPANY_NAME=%COMPANY_NAME%
    echo AUTO_UPDATE_YEAR=%AUTO_UPDATE_YEAR%
    echo AUTO_ADD_LICENSE=%AUTO_ADD_LICENSE%  :: <<<< NEUE ZEILE HINZUGEFÜGT
) > "%CONFIG_FILE%"
echo Konfiguration gespeichert.
goto :eof

:: Funktion: Logging
:log_message
if /i "%ENABLE_LOGGING%"=="true" (
    echo %date% %time% - %~1 >> "%LOG_FILE%"
)
goto :eof

:: Funktion: Backup umschalten
:toggle_backup
if /i "%CREATE_BACKUP%"=="true" (
    set "CREATE_BACKUP=false"
    echo Backup deaktiviert.
) else (
    set "CREATE_BACKUP=true"
    echo Backup aktiviert.
)
goto :eof

:: Funktion: Logging umschalten
:toggle_logging
if /i "%ENABLE_LOGGING%"=="true" (
    set "ENABLE_LOGGING=false"
    echo Logging deaktiviert.
) else (
    set "ENABLE_LOGGING=true"
    echo Logging aktiviert.
)
goto :eof

:toggle_auto_license
if /i "%AUTO_ADD_LICENSE%"=="true" (
    set "AUTO_ADD_LICENSE=false"
    echo Auto-Lizenz deaktiviert.
) else (
    set "AUTO_ADD_LICENSE=true"
    echo Auto-Lizenz aktiviert.
)
goto :eof

:: Funktion: Formatter-Stil ändern
:change_style
if /i "%FORMATTER_STYLE%"=="Google" (
    set "FORMATTER_STYLE=AOSP"
    echo Stil auf AOSP geändert.
) else (
    set "FORMATTER_STYLE=Google"
    echo Stil auf Google geändert.
)
goto :eof

:: Funktion: Einrückung ändern
:change_indent
set /p "new_indent=Neue Einrückung (2-8 Leerzeichen): "
if %new_indent% GEQ 2 if %new_indent% LEQ 8 (
    set "INDENT_SIZE=%new_indent%"
    echo Einrückung auf %new_indent% Leerzeichen gesetzt.
) else (
    echo Ungültige Eingabe. Bereich: 2-8
)
goto :eof

:: Funktion: Backup-Dateien aufräumen
:cleanup_backup_files
set "backup_count=0"
echo Suche nach Backup-Dateien...

for /r %%f in (*%BACKUP_SUFFIX%) do (
    echo Lösche: %%f
    del "%%f" 2>nul
    set /a backup_count+=1
)

echo %backup_count% Backup-Datei(en) gelöscht.
pause
goto :eof

:: Funktion: Java-Syntax validieren
:validate_java_syntax
set "target=%~1"
set "error_count=0"
set "valid_count=0"

if exist "%target%\*" (
    echo Validiere Java-Dateien in "%target%"...
    for %%f in ("%target%\*.java") do (
        call :validate_single_file "%%f"
    )
) else (
    call :validate_single_file "%target%"
)

echo.
echo Zusammenfassung:
echo - Gültige Dateien: %valid_count%
echo - Fehlerhafte Dateien: %error_count%
pause
goto :eof

:: Funktion: Einzelne Datei validieren
:validate_single_file
set "file_path=%~1"
set "file_name=%~nx1"

echo Prüfe: %file_name%
javac -cp . "%file_path%" 2>nul

if errorlevel 1 (
    echo   - SYNTAX-FEHLER
    set /a error_count+=1
) else (
    echo   - OK
    set /a valid_count+=1
    :: Lösche .class Datei
    del "%~dpn1.class" 2>nul
)
goto :eof

:: Funktion: Code-Statistiken
:calculate_statistics
set "java_files=0"
set "txt_files=0"
set "total_lines=0"
set "total_chars=0"

echo Analysiere Dateien im aktuellen Verzeichnis...

for %%f in (*.java) do (
    set /a java_files+=1
    call :count_lines "%%f"
)

for %%f in (*.txt) do (
    set /a txt_files+=1
    call :count_lines "%%f"
)

echo.
echo Statistiken:
echo - Java-Dateien: %java_files%
echo - TXT-Dateien: %txt_files%
echo - Gesamtzeilen: %total_lines%
echo - Gesamtzeichen: %total_chars%
pause
goto :eof

:: Funktion: Zeilen zählen
:count_lines
set "file_lines=0"
for /f %%i in ('find /c /v "" ^< "%~1"') do set "file_lines=%%i"
set /a total_lines+=file_lines

for %%i in ("%~1") do set /a total_chars+=%%~zi
goto :eof

:: ==================================================
:: LIZENZ-VERWALTUNG FUNKTIONEN
:: ==================================================

:: Funktion: Erstelle Standard-Lizenzvorlagen
:create_default_licenses
(
echo [MIT]
echo /*
echo  * MIT License
echo  *
echo  * Copyright ^(c^) {YEAR} {AUTHOR}
echo  *
echo  * Permission is hereby granted, free of charge, to any person obtaining a copy
echo  * of this software and associated documentation files ^(the "Software"^), to deal
echo  * in the Software without restriction, including without limitation the rights
echo  * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
echo  * copies of the Software, and to permit persons to whom the Software is
echo  * furnished to do so, subject to the following conditions:
echo  *
echo  * The above copyright notice and this permission notice shall be included in all
echo  * copies or substantial portions of the Software.
echo  *
echo  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
echo  * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
echo  * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
echo  * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
echo  * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
echo  * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
echo  * SOFTWARE.
echo  */
echo.
echo [Apache-2.0]
echo /*
echo  * Licensed to the Apache Software Foundation ^(ASF^) under one
echo  * or more contributor license agreements.  See the NOTICE file
echo  * distributed with this work for additional information
echo  * regarding copyright ownership.  The ASF licenses this file
echo  * to you under the Apache License, Version 2.0 ^(the
echo  * "License"^); you may not use this file except in compliance
echo  * with the License.  You may obtain a copy of the License at
echo  *
echo  *   http://www.apache.org/licenses/LICENSE-2.0
echo  *
echo  * Unless required by applicable law or agreed to in writing,
echo  * software distributed under the License is distributed on an
echo  * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
echo  * KIND, either express or implied.  See the License for the
echo  * specific language governing permissions and limitations
echo  * under the License.
echo  *
echo  * Copyright ^(c^) {YEAR} {AUTHOR}
echo  */
echo.
echo [GPL-3.0]
echo /*
echo  * This program is free software: you can redistribute it and/or modify
echo  * it under the terms of the GNU General Public License as published by
echo  * the Free Software Foundation, either version 3 of the License, or
echo  * ^(at your option^) any later version.
echo  *
echo  * This program is distributed in the hope that it will be useful,
echo  * but WITHOUT ANY WARRANTY; without even the implied warranty of
echo  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
echo  * GNU General Public License for more details.
echo  *
echo  * You should have received a copy of the GNU General Public License
echo  * along with this program.  If not, see ^<https://www.gnu.org/licenses/^>.
echo  *
echo  * Copyright ^(c^) {YEAR} {AUTHOR}
echo  */
echo.
echo [Custom]
echo /*
echo  * {COMPANY}
echo  * Copyright ^(c^) {YEAR} {AUTHOR}
echo  * All rights reserved.
echo  *
echo  * This software is proprietary and confidential.
echo  * Unauthorized copying of this file is strictly prohibited.
echo  */
) > "%LICENSE_FILE%"
goto :eof

:: Funktion: Lizenz-Header-Menü
:license_header_menu
echo Verfügbare Lizenzen:
call :list_available_licenses
echo.
echo [1] Einzelne Datei
echo [2] Ganzes Verzeichnis
echo [3] Rekursiv alle Unterordner
echo [4] Zurück zum Hauptmenü
echo.
set /p "license_choice=Auswahl: "

if "%license_choice%"=="1" call :add_license_single_file
if "%license_choice%"=="2" call :add_license_directory
if "%license_choice%"=="3" call :add_license_recursive
if "%license_choice%"=="4" goto :eof

goto :license_header_menu

:: Funktion: Verfügbare Lizenzen auflisten
:list_available_licenses
set "license_count=0"
for /f "tokens=1 delims=[]" %%A in ('findstr /r "^\[.*\]$" "%LICENSE_FILE%" 2^>nul') do (
    if not "%%A"=="" (
        set /a license_count+=1
        echo !license_count!. %%A
    )
)
goto :eof

:: Funktion: Lizenz zu einzelner Datei hinzufügen
:add_license_single_file
set /p "target_file=Pfad zur Java-Datei: "
if not exist "%target_file%" (
    echo FEHLER: Datei existiert nicht!
    goto :eof
)

call :select_license_type
call :add_license_header "%target_file%" "%selected_license%"
goto :eof

:: Funktion: Lizenz zu Verzeichnis hinzufügen
:add_license_directory
set /p "target_dir=Pfad zum Verzeichnis: "
if not exist "%target_dir%" (
    echo FEHLER: Verzeichnis existiert nicht!
    goto :eof
)

call :select_license_type
call :add_license_to_path "%target_dir%"
goto :eof

:: Funktion: Lizenz rekursiv hinzufügen
:add_license_recursive
call :select_license_type
call :add_license_recursive_impl "%cd%"
goto :eof

:: Funktion: Lizenztyp auswählen
:select_license_type
echo.
echo Wählen Sie eine Lizenz:
call :list_available_licenses
echo.
set /p "license_num=Lizenz-Nummer: "

set "license_count=0"
for /f "tokens=1 delims=[]" %%A in ('findstr /r "^\[.*\]$" "%LICENSE_FILE%" 2^>nul') do (
    if not "%%A"=="" (
        set /a license_count+=1
        if !license_count!==!license_num! set "selected_license=%%A"
    )
)

if "%selected_license%"=="" (
    echo Ungültige Auswahl!
    goto :select_license_type
)
goto :eof

:: Funktion: Lizenz-Header zu Datei hinzufügen
:add_license_header
set "file_path=%~1"
set "license_type=%~2"
set "temp_file=%temp%\license_temp_%random%.java"

:: Prüfe ob bereits Lizenz vorhanden
findstr /c:"Copyright" "%file_path%" >nul 2>&1
if not errorlevel 1 (
    echo   - Lizenz bereits vorhanden in %~nx1
    goto :eof
)

echo   - %license_type%-Lizenz hinzugefügt zu %~nx1

:: Extrahiere Lizenz-Template
call :extract_license_template "%license_type%" "%temp_file%"

:: Ersetze Platzhalter
call :replace_license_placeholders "%temp_file%"

:: Füge ursprünglichen Code hinzu
echo. >> "%temp_file%"
type "%file_path%" >> "%temp_file%"

:: Ersetze Original
move "%temp_file%" "%file_path%" >nul 2>&1
call :log_message "Lizenz hinzugefügt: %file_path%"
goto :eof

:: Funktion: Lizenz zu Pfad hinzufügen
:add_license_to_path
set "target_path=%~1"
set "file_count=0"

if exist "%target_path%\*" (
    for %%f in ("%target_path%\*.java") do (
        call :add_license_header "%%f" "%selected_license%"
        set /a file_count+=1
    )
    echo %file_count% Datei(en) mit Lizenz versehen.
) else (
    call :add_license_header "%target_path%" "%selected_license%"
)
goto :eof

:: Funktion: Rekursive Lizenz-Hinzufügung
:add_license_recursive_impl
set "dir_path=%~1"
set "total_count=0"

for /r "%dir_path%" %%f in (*.java) do (
    call :add_license_header "%%f" "%selected_license%"
    set /a total_count+=1
)

echo Insgesamt %total_count% Datei(en) mit Lizenz versehen.
goto :eof

:: Funktion: Lizenz-Vorlagen-Menü
:license_template_menu
echo [1] Vorlagen anzeigen
echo [2] Neue Vorlage hinzufügen
echo [3] Vorlage bearbeiten
echo [4] Vorlage löschen
echo [5] Zurück zum Hauptmenü
echo.
set /p "template_choice=Auswahl: "

if "%template_choice%"=="1" call :show_license_templates
if "%template_choice%"=="2" call :add_license_template
if "%template_choice%"=="3" call :edit_license_template
if "%template_choice%"=="4" call :delete_license_template
if "%template_choice%"=="5" goto :eof

pause
goto :license_template_menu

:: Funktion: Zeige Lizenz-Vorlagen
:show_license_templates
echo.
echo Verfügbare Lizenz-Vorlagen:
echo ==============================
type "%LICENSE_FILE%"
goto :eof

:: Funktion: Neue Lizenz-Vorlage hinzufügen
:add_license_template
echo.
set /p "new_license_name=Name der neuen Lizenz: "
echo.
echo Geben Sie den Lizenz-Header ein (mit {YEAR}, {AUTHOR}, {COMPANY} als Platzhalter):
echo Beenden Sie mit einer leeren Zeile.
echo.

echo. >> "%LICENSE_FILE%"
echo [%new_license_name%] >> "%LICENSE_FILE%"

:add_template_loop
set /p "license_line=Zeile: "
if "%license_line%"=="" goto :add_template_done
echo %license_line% >> "%LICENSE_FILE%"
goto :add_template_loop

:add_template_done
echo Lizenz-Vorlage "%new_license_name%" hinzugefügt.
goto :eof

:: Neue Einstellungsfunktionen
:change_default_license
call :list_available_licenses
set /p "new_default=Standard-Lizenz-Nummer: "
set "license_count=0"
for /f "tokens=1 delims=[]" %%A in ('findstr /r "^\[.*\]$" "%LICENSE_FILE%" 2^>nul') do (
    if not "%%A"=="" (
        set /a license_count+=1
        if !license_count!==!new_default! set "DEFAULT_LICENSE=%%A"
    )
)
echo Standard-Lizenz geändert zu: %DEFAULT_LICENSE%
goto :eof

:set_author_info
set /p "AUTHOR_NAME=Autor-Name: "
echo Autor-Name gesetzt: %AUTHOR_NAME%
goto :eof

:set_company_info
set /p "COMPANY_NAME=Firmen-Name: "
echo Firmen-Name gesetzt: %COMPANY_NAME%
goto :eof

:toggle_auto_year
if /i "%AUTO_UPDATE_YEAR%"=="true" (
    set "AUTO_UPDATE_YEAR=false"
    echo Auto-Jahr-Update deaktiviert.
) else (
    set "AUTO_UPDATE_YEAR=true"
    echo Auto-Jahr-Update aktiviert.
)
goto :eof

:: Funktion: Formatiere alle Java-Dateien rekursiv
:format_recursive_directory
set "dir_path=%~1"
set "total_count=0"

for /r "%dir_path%" %%f in (%JAVA_FILES_PATTERN%) do (
    call :format_file "%%f"
    set /a total_count+=1
)

if !total_count! EQU 0 (
    echo Keine Java-Dateien gefunden.
) else (
    echo Insgesamt !total_count! Datei(en) formatiert.
)
goto :eof

:: Funktion: Formatiere eine einzelne Java-Datei
:format_file
set "file_path=%~1"
set "file_name=%~nx1"
set "file_ext=%~x1"

echo Formatiere: %file_name%
call :log_message "Formatiere: %file_path%"

:: Erstelle Backup falls aktiviert
if /i "%CREATE_BACKUP%"=="true" (
    echo   - Erstelle Backup...
    copy "%file_path%" "%file_path%%BACKUP_SUFFIX%" >nul 2>&1
)

:: Unterschiedliche Behandlung für .java und .txt Dateien
if /i "%file_ext%"==".txt" (
    :: Für TXT-Dateien: Formatiere als Java-Code UND füge Lizenz hinzu
    call :format_txt_as_java "%file_path%"
) else (
    :: Für .java Dateien: Automatische Lizenz ZUERST hinzufügen (falls aktiviert und noch nicht vorhanden)
    if /i "%AUTO_ADD_LICENSE%"=="true" (
        :: Prüfe ob bereits Lizenz vorhanden
        findstr /c:"Copyright" "%file_path%" >nul 2>&1
        if errorlevel 1 (
            echo   - Füge Lizenz hinzu...
            set "selected_license=%DEFAULT_LICENSE%"
            call :add_license_header_without_check "%file_path%" "%selected_license%"
        ) else (
            echo   - Lizenz bereits vorhanden
        )
    )

    :: Formatiere die Java-Datei mit gewähltem Stil
    set "format_args=--replace"
    if /i "%FORMATTER_STYLE%"=="AOSP" set "format_args=--aosp --replace"

    java -jar "%FORMATTER_JAR%" %format_args% "%file_path%" 2>nul
)

:: Fehlerbehandlung für beide Dateitypen
if errorlevel 1 (
    echo   - FEHLER beim Formatieren von %file_name%
    call :log_message "FEHLER: %file_path%"
    if /i "%CREATE_BACKUP%"=="true" (
        if exist "%file_path%%BACKUP_SUFFIX%" (
            move "%file_path%%BACKUP_SUFFIX%" "%file_path%" >nul 2>&1
            echo   - Backup wiederhergestellt
        )
    )
) else (
    echo   - Erfolgreich formatiert
    call :log_message "Erfolgreich: %file_path%"
    
    if /i "%CREATE_BACKUP%"=="true" (
        if exist "%file_path%%BACKUP_SUFFIX%" (
            del "%file_path%%BACKUP_SUFFIX%" >nul 2>&1
        )
    )
)

goto :eof

:: Neue Hilfsfunktion: Lizenz ohne Check hinzufügen
:add_license_header_without_check
set "file_path=%~1"
set "license_type=%~2"
set "temp_file=%temp%\license_temp_%random%.java"

echo   - %license_type%-Lizenz wird hinzugefügt zu %~nx1

:: Extrahiere Lizenz-Template
call :extract_license_template "%license_type%" "%temp_file%"

:: Ersetze Platzhalter
call :replace_license_placeholders "%temp_file%"

:: Füge ursprünglichen Code hinzu
echo. >> "%temp_file%"
type "%file_path%" >> "%temp_file%"

:: Ersetze Original
move "%temp_file%" "%file_path%" >nul 2>&1
call :log_message "Lizenz hinzugefügt: %file_path%"
goto :eof

:: Funktion: Formatiere TXT-Datei als Java-Code (ohne automatische Lizenz)
:format_txt_as_java_only
set "txt_file=%~1"
set "temp_java=%temp%\temp_java_code_%random%.java"

echo   - Erstelle temporäre Java-Datei...
copy "%txt_file%" "%temp_java%" >nul 2>&1

echo   - Formatiere als Java-Code...
java -jar "%FORMATTER_JAR%" --replace "%temp_java%" 2>nul

if errorlevel 1 (
    echo   - FEHLER: Datei enthält möglicherweise ungültigen Java-Code
    if exist "%temp_java%" del "%temp_java%" >nul 2>&1
    exit /b 1
) else (
    echo   - Schreibe formatierten Code zurück...
    copy "%temp_java%" "%txt_file%" >nul 2>&1
    del "%temp_java%" >nul 2>&1
    echo   - TXT-Datei erfolgreich formatiert
)

goto :eof

:: Zusätzlich benötigte Funktionen:
:extract_license_template
set "license_name=%~1"
set "output_file=%~2"
set "in_license=false"

if exist "%output_file%" del "%output_file%" >nul 2>&1

for /f "usebackq delims=" %%A in ("%LICENSE_FILE%") do (
    set "line=%%A"
    if "!line!"=="[%license_name%]" (
        set "in_license=true"
    ) else if "!line:~0,1!"=="[" (
        set "in_license=false"
    ) else if "!in_license!"=="true" (
        if not "!line!"=="" echo !line!>> "%output_file%"
    )
)
goto :eof

:replace_license_placeholders
set "template_file=%~1"
set "temp_replace=%temp%\license_replace_%random%.tmp"

:: Aktuelles Jahr ermitteln
for /f "tokens=1-3 delims=/ " %%A in ('date /t') do set "current_year=%%C"
if "%current_year%"=="" for /f "tokens=3 delims=. " %%A in ('date /t') do set "current_year=%%A"

:: Standard-Werte setzen falls leer
if "%AUTHOR_NAME%"=="" set "AUTHOR_NAME=Unbekannter Autor"
if "%COMPANY_NAME%"=="" set "COMPANY_NAME=Unbekannte Firma"

:: Platzhalter ersetzen
for /f "usebackq delims=" %%A in ("%template_file%") do (
    set "line=%%A"
    set "line=!line:{YEAR}=%current_year%!"
    set "line=!line:{AUTHOR}=%AUTHOR_NAME%!"
    set "line=!line:{COMPANY}=%COMPANY_NAME%!"
    echo !line!>> "%temp_replace%"
)

move "%temp_replace%" "%template_file%" >nul 2>&1
goto :eof

:: Funktion: Formatiere TXT-Datei als Java-Code
:format_txt_as_java
set "txt_file=%~1"
set "temp_java=%temp%\temp_java_code_%random%.java"

echo   - Erstelle temporäre Java-Datei...
copy "%txt_file%" "%temp_java%" >nul 2>&1

echo   - Formatiere als Java-Code...
java -jar "%FORMATTER_JAR%" --replace "%temp_java%" 2>nul

if errorlevel 1 (
    echo   - FEHLER: Datei enthält möglicherweise ungültigen Java-Code
    if exist "%temp_java%" del "%temp_java%" >nul 2>&1
    exit /b 1
) else (
    echo   - Schreibe formatierten Code zurück...
    copy "%temp_java%" "%txt_file%" >nul 2>&1
    del "%temp_java%" >nul 2>&1
    echo   - TXT-Datei erfolgreich formatiert
    
    :: Automatische Lizenz für TXT-Dateien
    if /i "%AUTO_ADD_LICENSE%"=="true" (
        echo   - Füge Lizenz zu TXT-Datei hinzu...
        set "selected_license=%DEFAULT_LICENSE%"
        call :add_license_header "%txt_file%" "%selected_license%"
    )
)

goto :eof

goto :eof
:: Funktion: Formatiere TXT-Dateien in einem Verzeichnis
:format_txt_files_in_directory
set "dir_path=%~1"
set "file_count=0"

for %%f in ("%dir_path%\%TXT_FILES_PATTERN%") do (
    call :format_txt_as_java "%%f"
    if not errorlevel 1 set /a file_count+=1
)

if !file_count! EQU 0 (
    echo Keine TXT-Dateien formatiert (keine gefunden oder Fehler).
) else (
    echo !file_count! TXT-Datei(en) formatiert.
)
goto :eof

:end
echo.
echo Formatierung abgeschlossen!
echo.
pause