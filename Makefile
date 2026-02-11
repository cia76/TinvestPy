.PHONY: help install venv deactivate run-accounts run-bars run-connect run-stream run-ticker \
		run-transactions clean update info

# Цвета для вывода
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
CYAN := \033[0;36m
MAGENTA := \033[0;35m
NC := \033[0m # No Color

# Для названия, версии, описания и Python версии
PROJECT_NAME := TinvestPy
PROJECT_VERSION := $(shell grep -E '^version\s*=' pyproject.toml | head -1 | sed -E 's/.*"([^"]+)".*/\1/')
PROJECT_DESCRIPTION := Библиотека-обертка, которая позволяет работать с T-Invest API брокера Т-Инвестиции из Python
PYTHON_REQUIRED := 3.12
PROJECT_AUTHOR_NAME := Чечет Игорь Александрович
PROJECT_URL_HOMEPAGE := https://github.com/cia76/TinvestPy
PROJECT_URL_REPOSITORY := https://github.com/cia76/TinvestPy

# Путь к примерам (автоматическое определение)
EXAMPLES_PATH := $(shell if [ -d "Examples" ]; then echo "Examples"; \
    elif [ -d "TinvestPy/Examples" ]; then echo "TinvestPy/Examples"; \
    elif [ -d "${PROJECT_NAME}/Examples" ]; then echo "${PROJECT_NAME}/Examples"; \
    else echo "."; fi)

# Цель по умолчанию - показывает справку
help:
	@printf "\n${CYAN}🐍 ДОСТУПНЫЕ КОМАНДЫ ДЛЯ ${PROJECT_NAME} v${PROJECT_VERSION}${NC}\n\n"
	@printf "${GREEN}Основные команды:${NC}\n"
	@printf "  ${YELLOW}make venv${NC}             - ${CYAN}⚙️ Создать виртуальное окружение${NC}\n"
	@printf "  ${YELLOW}make install${NC}          - ${CYAN}📦 Установить пакет и зависимости${NC}\n"
	@printf "  ${YELLOW}make deactivate${NC}       - ${CYAN}🚪 Деактивировать виртуальное окружение${NC}\n\n"

	@printf "${GREEN}Запуск примеров:${NC}\n"
	@printf "  ${YELLOW}make run-accounts${NC}     - ${CYAN}▶️ Accounts.py (Подключение ко всем торговым счетам)${NC}\n"
	@printf "  ${YELLOW}make run-bars${NC}         - ${CYAN}▶️ Bars.py (Получение бар от брокера)${NC}\n"
	@printf "  ${YELLOW}make run-connect${NC}      - ${CYAN}▶️ Connect.py (Проверка работы подписок)${NC}\n"
	@printf "  ${YELLOW}make run-stream${NC}       - ${CYAN}▶️ Stream.py (Подпика на котировки)${NC}\n"
	@printf "  ${YELLOW}make run-ticker${NC}       - ${CYAN}▶️ Ticker.py (Загрузка исторических данных)${NC}\n"
	@printf "  ${YELLOW}make run-transactions${NC} - ${CYAN}▶️ Transactions.py (Запуск тестовой торговой системы)${NC}\n\n"

	@printf "${GREEN}Вспомогательные команды:${NC}\n"
	@printf "  ${YELLOW}make update${NC}           - ${CYAN}🔄 Обновить пакет из GitHub${NC}\n"
	@printf "  ${YELLOW}make clean${NC}            - ${CYAN}🗑️ Очистка временных файлов и сборок${NC}\n"
	@printf "  ${YELLOW}make info${NC}             - ${CYAN}ℹ️ Информация о проекте${NC}\n\n"

# Создание виртуального окружения
venv:
	@printf "\n${CYAN}🐍 СОЗДАНИЕ ВИРТУАЛЬНОГО ОКРУЖЕНИЯ ДЛЯ ${PROJECT_NAME}${NC}\n\n"
	@printf "${YELLOW}Требуемая версия Python: >=${PYTHON_REQUIRED}${NC}\n\n"
	@if [ ! -d ".venv" ]; then \
        printf "${YELLOW}⚙️ Создаю виртуальное окружение...${NC}\n"; \
        if command -v uv > /dev/null; then \
            printf "${YELLOW}🚀 Использую UV для создания окружения...${NC}\n"; \
            uv venv .venv --python python3.12; \
        elif command -v python3.12 > /dev/null; then \
            printf "${YELLOW}🐍 Использую python3.12...${NC}\n"; \
            python3.12 -m venv .venv; \
        elif command -v python3 > /dev/null; then \
            printf "${YELLOW}🐍 Использую python3...${NC}\n"; \
            python3 -m venv .venv; \
        elif command -v python > /dev/null; then \
            printf "${YELLOW}🐍 Использую python...${NC}\n"; \
            python -m venv .venv; \
        else \
            printf "${RED}❌ Python не найден!${NC}\n"; \
            printf "${YELLOW}Установите Python ${PYTHON_REQUIRED} или выше.${NC}\n"; \
            exit 1; \
        fi; \
        if [ $$? -eq 0 ] && [ -f ".venv/bin/activate" -o -f ".venv/Scripts/activate" ]; then \
            printf "${GREEN}✓ Виртуальное окружение создано в .venv${NC}\n\n"; \
            if command -v uv > /dev/null; then \
                printf "${YELLOW}ℹ️ UV обнаружен, активирую окружение...${NC}\n"; \
                source .venv/bin/activate; \
                printf "${GREEN}✓ Окружение активировано${NC}\n\n"; \
            fi; \
        else \
            printf "${RED}❌ Ошибка создания виртуального окружения${NC}\n"; \
            printf "${YELLOW}Попробуйте создать окружение с помощью virtualenv:${NC}\n"; \
            printf "  virtualenv .venv\n"; \
            exit 1; \
        fi; \
    else \
        printf "${YELLOW}📁 Виртуальное окружение уже существует в .venv${NC}\n\n"; \
    fi
	@printf "${CYAN}🐍 Активируйте виртуальное окружение:${NC}\n"
	@printf "  ${GREEN}source .venv/bin/activate${NC}    # Linux/Mac\n"
	@printf "  ${GREEN}.venv\\Scripts\\activate${NC}         # Windows\n\n"
	@printf "${YELLOW}После активации выполните:${NC}\n"
	@printf "  ${YELLOW}make install${NC} - для установки пакета\n\n"

# Деактивация виртуального окружения
deactivate:
	@printf "\n${CYAN}🚪 ДЕАКТИВАЦИЯ ВИРТУАЛЬНОГО ОКРУЖЕНИЯ${NC}\n\n"
	@if [ -n "$$VIRTUAL_ENV" ]; then \
		printf "${GREEN}✓ Виртуальное окружение активно: $$VIRTUAL_ENV${NC}\n\n"; \
		printf "${YELLOW}Команда для деактивации:${NC}\n\n"; \
		printf "  ${GREEN}deactivate${NC}\n\n"; \
		printf "${CYAN}После деактивации выполните:${NC}\n"; \
		printf "  ${YELLOW}source .venv/bin/activate${NC}    # Для повторной активации (Linux/Mac)\n"; \
		printf "  ${YELLOW}.venv\\Scripts\\activate${NC}         # Для повторной активации (Windows)\n\n"; \
	else \
		printf "${YELLOW}⚠️ Виртуальное окружение не активно${NC}\n\n"; \
		printf "${CYAN}Текущее окружение:${NC}\n"; \
		printf "  ${GREEN}system Python${NC}\n\n"; \
	fi

# Установка пакета 
install: 
	@printf "\n${CYAN}📦 УСТАНОВКА ${PROJECT_NAME}${NC}\n\n"
	
	@# Проверяем виртуальное окружение
	@if [ -z "$$VIRTUAL_ENV" ]; then \
		printf "${YELLOW}⚠️ ВНИМАНИЕ: Виртуальное окружение не активировано!${NC}\n\n"; \
		printf "${CYAN}Рекомендуется работать в виртуальном окружении:${NC}\n\n"; \
		printf "${GREEN}1. Создайте виртуальное окружение:${NC}\n"; \
		printf "   ${YELLOW}make venv${NC}\n\n"; \
		printf "${GREEN}2. Активируйте его:${NC}\n"; \
		printf "   ${YELLOW}source .venv/bin/activate${NC}    # Linux/Mac\n"; \
		printf "   ${YELLOW}.venv\\Scripts\\activate${NC}         # Windows\n\n"; \
		printf "${YELLOW}Продолжить установку без виртуального окружения? (y/n): ${NC}"; \
		read choice; \
		if [ "$$choice" != "y" ] && [ "$$choice" != "Y" ]; then \
			printf "${YELLOW}Установка отменена.${NC}\n"; \
			exit 0; \
		fi; \
		printf "\n"; \
	fi
	
	@printf "${YELLOW}⚙️ Установка ${PROJECT_NAME}...${NC}\n\n"
	@if pip install git+https://github.com/cia76/TinvestPy.git; then \
		printf "\n${GREEN}✅ ${PROJECT_NAME} успешно установлен!${NC}\n\n"; \
	else \
		printf "\n${RED}❌ Ошибка при установке${NC}\n"; \
		printf "${YELLOW}Попробуйте установить локальную версию:${NC}\n"; \
		printf "  ${YELLOW}pip install .${NC}\n\n"; \
		exit 1; \
	fi
	
	@printf "${MAGENTA}🔑 ВАЖНАЯ ИНФОРМАЦИЯ 🔑${NC}\n\n"
	@printf "${YELLOW}⚠️ Для первого запуска необходим токен T-Invest API!${NC}\n"
	@printf "Получить токен можно в настройках профиля ${CYAN}Т-Инвестиций${NC}\n\n"
	
	@printf "${CYAN}📚 ИНСТРУКЦИЯ:${NC}\n"
	@printf "1. Откройте файл: ${GREEN}Examples/Accounts.py${NC}\n"
	@printf "2. Найдите строку: ${YELLOW}tp_provider = TinvestPy()${NC}\n"
	@printf "3. Замените ее на: ${GREEN}tp_provider = TinvestPy('ВАШ_ТОКЕН_ЗДЕСЬ')${NC}\n"
	@printf "4. После первого запуска ${GREEN}Accounts.py${NC} токен можно удалить из ${GREEN}tp_provider = TinvestPy('ВАШ_ТОКЕН_ЗДЕСЬ')${NC}\n\n"
	
	@printf "${GREEN}🚀 ${PROJECT_NAME} готов к использованию!${NC}\n\n"
	@printf "Используйте следующие команды ${YELLOW}make${NC} для запуска примеров:\n\n"
	@printf "     ${YELLOW}make run-accounts${NC}    - запуск Accounts.py\n"
	@printf "     ${YELLOW}make run-bars${NC}        - запуск Bars.py\n"
	@printf "     ${YELLOW}make run-connect${NC}     - запуск Connect.py\n"
	@printf "     ${YELLOW}make run-stream${NC}      - запуск Stream.py\n"
	@printf "     ${YELLOW}make run-ticker${NC}      - запуск Ticker.py\n"
	@printf "     ${YELLOW}make run-transactions${NC}- запуск Transactions.py\n\n"

# Запуск примеров из папки Examples
run-accounts:
	@printf "\n${CYAN}▶️ ЗАПУСК ПРИМЕРА Accounts.py (${PROJECT_NAME} v${PROJECT_VERSION})${NC}\n\n"
	@printf "${CYAN}Описание:${NC} Информация о счетах, балансе и портфеле.\n"
	@printf "${YELLOW}⚠️ Убедитесь, что токен установлен при первом запуске.${NC}\n\n"
	@printf "${CYAN}Продолжить запуск? (y/n): ${NC}"; \
	read choice; \
	if [ "$$choice" = "y" ] || [ "$$choice" = "Y" ]; then \
		printf "${GREEN}▶️ Запускаю Accounts.py...${NC}\n\n"; \
		cd ${EXAMPLES_PATH} && python Accounts.py; \
	else \
		printf "${YELLOW}Запуск отменен${NC}\n"; \
	fi

run-bars:
	@( \
		printf "\n${CYAN}▶️ ЗАПУСК ПРИМЕРА Bars.py (${PROJECT_NAME} v${PROJECT_VERSION})${NC}\n\n"; \
		printf "${CYAN}Описание:${NC} Получение исторических данных (свечей).\n"; \
		printf "${YELLOW}⚠️ Убедитесь, что токен установлен при первом запуске.${NC}\n\n"; \
		printf "${CYAN}Продолжить запуск? (y/n): ${NC}"; \
		read choice; \
		if [ "$$choice" = "y" ] || [ "$$choice" = "Y" ]; then \
			printf "${GREEN}▶️ Подготовка к запуску Bars.py...${NC}\n\n"; \
			printf "${YELLOW}🔍 Проверка pandas...${NC}\n"; \
			if python -c "import pandas" 2>/dev/null; then \
				printf "${GREEN}✓ pandas уже установлен${NC}\n"; \
				PANDAS_INSTALLED=0; \
			else \
				printf "${YELLOW}📦 Устанавливаю pandas...${NC}\n"; \
				if pip install pandas --quiet > /dev/null 2>&1; then \
					printf "${GREEN}✓ pandas установлен${NC}\n"; \
					PANDAS_INSTALLED=1; \
				else \
					printf "${RED}❌ Ошибка установки pandas${NC}\n"; \
					PANDAS_INSTALLED=0; \
				fi; \
			fi; \
			printf "\n"; \
			printf "${YELLOW}📁 Создание папок для данных...${NC}\n"; \
			mkdir -p ${EXAMPLES_PATH}/../../Data/Tinkoff; \
			if [ -d "${EXAMPLES_PATH}/../../Data/Tinkoff" ]; then \
				printf "${GREEN}✓ Папка Data/Tinkoff создана${NC}\n\n"; \
			else \
				printf "${YELLOW}⚠️ Не удалось создать папку Data/Tinkoff${NC}\n\n"; \
			fi; \
			printf "${GREEN}🚀 Запускаю Bars.py...${NC}\n\n"; \
			cd ${EXAMPLES_PATH} && python Bars.py; \
			SCRIPT_EXIT_CODE=$$?; \
			printf "\n"; \
			if [ "$$PANDAS_INSTALLED" = "1" ]; then \
				printf "${YELLOW}🗑️ Удаляю pandas...${NC}\n"; \
				pip uninstall pandas -y --quiet > /dev/null 2>&1 && \
					printf "${GREEN}✓ pandas удален${NC}\n" || \
					printf "${YELLOW}⚠️ Не удалось удалить pandas${NC}\n"; \
				printf "\n"; \
			fi; \
			exit $$SCRIPT_EXIT_CODE; \
		else \
			printf "${YELLOW}Запуск отменен${NC}\n"; \
		fi \
	)

run-connect:
	@printf "\n${CYAN}▶️ ЗАПУСК ПРИМЕРА Connect.py (${PROJECT_NAME} v${PROJECT_VERSION})${NC}\n\n"
	@printf "${CYAN}Описание:${NC} Пример подключения к T-Invest API.\n"
	@printf "${YELLOW}⚠️ Убедитесь, что токен установлен при первом запуске.${NC}\n\n"
	@printf "${CYAN}Продолжить запуск? (y/n): ${NC}"; \
	read choice; \
	if [ "$$choice" = "y" ] || [ "$$choice" = "Y" ]; then \
		printf "${GREEN}▶️ Запускаю Connect.py...${NC}\n\n"; \
		cd ${EXAMPLES_PATH} && python Connect.py; \
	else \
		printf "${YELLOW}Запуск отменен${NC}\n"; \
	fi

run-stream:
	@printf "\n${CYAN}▶️ ЗАПУСК ПРИМЕРА Stream.py (${PROJECT_NAME} v${PROJECT_VERSION})${NC}\n\n"
	@printf "${CYAN}Описание:${NC} Работа с потоковыми данными (WebSocket).\n"
	@printf "${YELLOW}⚠️ Убедитесь, что токен установлен при первом запуске.${NC}\n\n"
	@printf "${CYAN}Продолжить запуск? (y/n): ${NC}"; \
	read choice; \
	if [ "$$choice" = "y" ] || [ "$$choice" = "Y" ]; then \
		printf "${GREEN}▶️ Запускаю Stream.py...${NC}\n\n"; \
		cd ${EXAMPLES_PATH} && python Stream.py; \
	else \
		printf "${YELLOW}Запуск отменен${NC}\n"; \
	fi

run-ticker:
	@printf "\n${CYAN}▶️ ЗАПУСК ПРИМЕРА Ticker.py (${PROJECT_NAME} v${PROJECT_VERSION})${NC}\n\n"
	@printf "${CYAN}Описание:${NC} Получение информации о тикере.\n"
	@printf "${YELLOW}⚠️ Убедитесь, что токен установлен при первом запуске.${NC}\n\n"
	@printf "${CYAN}Продолжить запуск? (y/n): ${NC}"; \
	read choice; \
	if [ "$$choice" = "y" ] || [ "$$choice" = "Y" ]; then \
		printf "${GREEN}▶️ Запускаю Ticker.py...${NC}\n\n"; \
		cd ${EXAMPLES_PATH} && python Ticker.py; \
	else \
		printf "${YELLOW}Запуск отменен${NC}\n"; \
	fi

run-transactions:
	@printf "\n${CYAN}▶️ ЗАПУСК ПРИМЕРА Transactions.py (${PROJECT_NAME} v${PROJECT_VERSION})${NC}\n\n"
	@printf "${CYAN}Описание:${NC} История операций по счету.\n"
	@printf "${YELLOW}⚠️ Убедитесь, что токен установлен при первом запуске.${NC}\n\n"
	@printf "${CYAN}Продолжить запуск? (y/n): ${NC}"; \
	read choice; \
	if [ "$$choice" = "y" ] || [ "$$choice" = "Y" ]; then \
		printf "${GREEN}▶️ Запускаю Transactions.py...${NC}\n\n"; \
		cd ${EXAMPLES_PATH} && python Transactions.py; \
	else \
		printf "${YELLOW}Запуск отменен${NC}\n"; \
	fi

# Обновление пакета из GitHub
update:
	@printf "\n${CYAN}🔄 ОБНОВЛЕНИЕ ${PROJECT_NAME} ИЗ GITHUB${NC}\n\n"
	
	@# Проверяем виртуальное окружение
	@if [ -z "$$VIRTUAL_ENV" ]; then \
		printf "${YELLOW}⚠️ ВНИМАНИЕ: Виртуальное окружение не активировано!${NC}\n\n"; \
		printf "${CYAN}Рекомендуется работать в виртуальном окружении:${NC}\n\n"; \
		printf "${GREEN}1. Создайте виртуальное окружение:${NC}\n"; \
		printf "   ${YELLOW}make venv${NC}\n\n"; \
		printf "${GREEN}2. Активируйте его:${NC}\n"; \
		printf "   ${YELLOW}source .venv/bin/activate${NC}    # Linux/Mac\n"; \
		printf "   ${YELLOW}.venv\\Scripts\\activate${NC}         # Windows\n\n"; \
		printf "${YELLOW}Продолжить обновление без виртуального окружения? (y/n): ${NC}"; \
		read choice; \
		if [ "$$choice" != "y" ] && [ "$$choice" != "Y" ]; then \
			printf "${YELLOW}Обновление отменено.${NC}\n"; \
			exit 0; \
		fi; \
		printf "\n"; \
	fi
	
	@printf "${YELLOW}⚙️ Обновление ${PROJECT_NAME} из GitHub...${NC}\n\n"
	@if pip install --upgrade --force-reinstall git+https://github.com/cia76/TinvestPy.git; then \
		printf "\n${GREEN}✅ ${PROJECT_NAME} успешно обновлен!${NC}\n\n"; \
	else \
		printf "\n${RED}❌ Ошибка при обновлении${NC}\n\n"; \
		exit 1; \
	fi

# Очистка временных файлов и виртуального окружения (опционально)
clean:
	@printf "\n${CYAN}🗑️ ОЧИСТКА ВРЕМЕННЫХ ФАЙЛОВ ${PROJECT_NAME}${NC}\n\n"
	@printf "${YELLOW}🔍 Поиск log файлов...${NC}\n"
	@LOG_FILES=$$(find ${EXAMPLES_PATH} -name "*.log" -type f 2>/dev/null | wc -l); \
	if [ "$$LOG_FILES" -gt 0 ]; then \
		printf "${YELLOW}⚠️ Найдено log файлов: $$LOG_FILES${NC}\n"; \
		printf "${RED}Удалить все log файлы? (y/n): ${NC}"; \
		read choice; \
		if [ "$$choice" = "y" ] || [ "$$choice" = "Y" ]; then \
			find ${EXAMPLES_PATH} -name "*.log" -type f -delete 2>/dev/null; \
			printf "${GREEN}✓ Log файлы удалены${NC}\n\n"; \
		else \
			printf "${YELLOW}✗ Сохраняю log файлы${NC}\n\n"; \
		fi; \
	else \
		printf "${GREEN}✓ Log файлы не найдены${NC}\n\n"; \
	fi
	
	@if [ -d ".venv" ]; then \
		printf "${YELLOW}⚠️ Обнаружено виртуальное окружение .venv${NC}\n"; \
		printf "${RED}Удалить виртуальное окружение? (y/n): ${NC}"; \
		read choice; \
		if [ "$$choice" = "y" ] || [ "$$choice" = "Y" ]; then \
			printf "${YELLOW}Удаляю .venv...${NC}\n"; \
			rm -rf .venv; \
			printf "${GREEN}✓ Виртуальное окружение удалено${NC}\n\n"; \
		else \
			printf "${YELLOW}✗ Сохраняю .venv${NC}\n\n"; \
		fi; \
	fi
	
	@printf "${YELLOW}⚙️ Автоматическая очистка...${NC}\n"
	@printf "  ${YELLOW}Кэш Python...${NC}\n"
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type f -name "*.pyo" -delete 2>/dev/null || true
	@printf "  ${YELLOW}Кэш инструментов...${NC}\n"
	@find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".hypothesis" -exec rm -rf {} + 2>/dev/null || true
	@printf "  ${YELLOW}Файлы сборки...${NC}\n"
	@if [ -d "dist" ]; then rm -rf dist; fi
	@if [ -d "build" ]; then rm -rf build; fi
	@if [ -d "${PROJECT_NAME}.egg-info" ]; then rm -rf ${PROJECT_NAME}.egg-info; fi
	@find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	@printf "  ${YELLOW}Отчеты...${NC}\n"
	@find . -type f -name ".coverage" -delete 2>/dev/null || true
	@find . -type f -name "coverage.xml" -delete 2>/dev/null || true
	@find . -type f -name "*.coverage" -delete 2>/dev/null || true
	
	@printf "\n${GREEN}✅ ОЧИСТКА ЗАВЕРШЕНА!${NC}\n\n"

# Информация о проекте
info:
	@printf "\n${CYAN}ℹ️ ИНФОРМАЦИЯ О ПРОЕКТЕ ${PROJECT_NAME}${NC}\n\n"
	@printf "${GREEN}Название:${NC} ${PROJECT_NAME}\n"
	@printf "${GREEN}Версия:${NC} ${PROJECT_VERSION}\n"
	@printf "${GREEN}Автор:${NC} ${PROJECT_AUTHOR_NAME}\n"
	@printf "${GREEN}Описание:${NC} ${PROJECT_DESCRIPTION}\n"
	@printf "${GREEN}Репозиторий:${NC} ${PROJECT_URL_REPOSITORY}\n"
	@printf "${GREEN}Домашняя страница:${NC} ${PROJECT_URL_HOMEPAGE}\n\n"
	
	@printf "${CYAN}🐍 ТЕХНИЧЕСКАЯ ИНФОРМАЦИЯ:${NC}\n"
	@printf "${GREEN}Зависимости:${NC} keyring, grpcio, protobuf, googleapis-common-protos, types-protobuf\n"
	@printf "${GREEN}Требуемый Python:${NC} >=${PYTHON_REQUIRED}\n\n"
	
	@printf "${CYAN}📚 ИСПОЛЬЗОВАНИЕ:${NC}\n"
	@printf "Примеры использования находятся в папке ${GREEN}${EXAMPLES_PATH}/${NC}\n"
	@printf "Для первого запуска требуется токен ${CYAN}T-Invest API${NC}\n"
	@printf "Получить токен можно в настройках профиля ${CYAN}Т-Инвестиций.${NC}\n\n"
	
	@printf "${MAGENTA}🚀 КОМАНДЫ ДЛЯ НАЧАЛА РАБОТЫ:${NC}\n"
	@printf "1. ${YELLOW}make venv${NC}       - создать виртуальное окружение\n"
	@printf "2. ${YELLOW}make install${NC}    - установить пакет\n"
	@printf "3. ${YELLOW}Добавить токен в tp_provider = TinvestPy()${NC}\n"
	@printf "4. ${YELLOW}make run-*${NC}      - запустить примеры (вместо * подставить:\n"
	@printf "     ${YELLOW}accounts${NC}      - для Accounts.py\n"
	@printf "     ${YELLOW}bars${NC}          - для Bars.py\n"
	@printf "     ${YELLOW}connect${NC}       - для Connect.py\n"
	@printf "     ${YELLOW}stream${NC}        - для Stream.py\n"
	@printf "     ${YELLOW}ticker${NC}        - для Ticker.py\n"
	@printf "     ${YELLOW}transactions${NC}  - для Transactions.py\n"
	@printf "5. ${YELLOW}make deactivate${NC} - деактивировать окружение\n\n"