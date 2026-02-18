.PHONY: help install venv run-accounts run-bars run-connect run-stream run-ticker \
		run-transactions clean update info

# Цвета для вывода
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
CYAN := \033[0;36m
MAGENTA := \033[0;35m
NC := \033[0m

# Переменные для парсинга данных из pyproject.toml
PROJECT_NAME := TinvestPy
PROJECT_VERSION := $(shell grep -E '^version\s*=\s*"' pyproject.toml | head -1 | sed -E 's/.*"([0-9.]+)".*/\1/')
PROJECT_DESCRIPTION := Библиотека-обертка, которая позволяет работать с T-Invest API брокера Т-Инвестиции из Python
PYTHON_REQUIRED := 3.12
PROJECT_DEPS := $(shell grep -E '^dependencies\s*=\s*\[' pyproject.toml -A 20 | \
                grep -E '"[^"]+"' | \
                grep -v "github.com\|grpc/\|://\|https\?://" | \
                sed -E 's/.*"([^"]+)".*/\1/' | \
                sed -E 's/[>=<~!].*//' | \
                tr '\n' ' ')
PROJECT_AUTHOR_NAME := Чечет Игорь Александрович
PROJECT_URL_HOMEPAGE := https://github.com/cia76/TinvestPy
PROJECT_URL_REPOSITORY := https://github.com/cia76/TinvestPy

# Переменные для виртуального окружения
VENV_DIR = .venv
PYTHON_CMD = python

# Скрываем вывод пути директориии при рекурсивном вызове make
MAKEFLAGS += --no-print-directory 

# Путь к примерам (автоматическое определение)
EXAMPLES_PATH := $(shell if [ -d "Examples" ]; then echo "Examples"; \
    elif [ -d "TinvestPy/Examples" ]; then echo "TinvestPy/Examples"; \
    elif [ -d "${PROJECT_NAME}/Examples" ]; then echo "${PROJECT_NAME}/Examples"; \
    else echo "."; fi)

# Цель - Показывает справку
help:
	@printf "\n${CYAN}🐍 ДОСТУПНЫЕ КОМАНДЫ ДЛЯ ${PROJECT_NAME} v${PROJECT_VERSION}${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"
	
	@printf "${GREEN}📦ОСНОВНЫЕ КОМАНДЫ:${NC}\n"
	@printf "  ${YELLOW}make venv${NC}              ${CYAN}⚙️  Создать виртуальное окружение\n"
	@printf "  ${YELLOW}make install${NC}           ${CYAN}📦 Установить ${PROJECT_NAME} и зависимости${NC}\n"
	@printf "  ${YELLOW}make update${NC}            ${CYAN}🔄 Обновить ${PROJECT_NAME} до актуальной версии\n\n"
	
	@printf "${GREEN}▶️ ЗАПУСК ПРИМЕРОВ (из папки ${EXAMPLES_PATH}):${NC}\n"
	@printf "  ${YELLOW}make run-connect${NC}       ${CYAN}🔑 Connect.py (Ввод токена и проверка работы запросов/ответов и подписок)${NC}\n"
	@printf "  ${YELLOW}make run-ticker${NC}        ${CYAN}📊 Ticker.py (Спецификация тикера)${NC}\n"
	@printf "  ${YELLOW}make run-bars${NC}          ${CYAN}📈 Bars.py (История тикера)${NC}\n"
	@printf "  ${YELLOW}make run-accounts${NC}      ${CYAN}💰 Accounts.py (Все торговые счета, позиции и заявки)${NC}\n"
	@printf "  ${YELLOW}make run-stream${NC}        ${CYAN}📡 Stream.py (Подписка на котировки)${NC}\n"
	@printf "  ${YELLOW}make run-transactions${NC}  ${CYAN}🔄 Transactions.py (Постановка и снятие заявок)${NC}\n\n"
	
	@printf "${GREEN}🛠️ ВСПОМОГАТЕЛЬНЫЕ КОМАНДЫ:${NC}\n"
	@printf "  ${YELLOW}make clean${NC}             ${CYAN}🗑️  Очистка временных файлов${NC}\n"
	@printf "  ${YELLOW}make info${NC}              ${CYAN}ℹ️  Подробная информация о проекте${NC}\n"
	@printf "  ${YELLOW}make help${NC}              ${CYAN}❓ Показать это сообщение${NC}\n\n"

# Цель - Создание виртуального окружения
venv:
	@printf "\n${CYAN}🐍 СОЗДАНИЕ ВИРТУАЛЬНОГО ОКРУЖЕНИЯ ДЛЯ ${PROJECT_NAME}${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	@printf "${YELLOW}🐍 Требуемая версия Python: ${PYTHON_REQUIRED}${NC}\n\n"
	
	@if [ ! -d "$(VENV_DIR)" ]; then \
		printf "${YELLOW}⚙️ Создаю виртуальное окружение с Python ${PYTHON_REQUIRED}...${NC}\n"; \
		$(PYTHON_CMD)$(PYTHON_REQUIRED) -m venv $(VENV_DIR); \
		\
		if [ $$? -eq 0 ]; then \
			printf "${GREEN}✅ Виртуальное окружение создано в $(VENV_DIR)${NC}\n"; \
			printf "${YELLOW}⚙️ Обновление pip...${NC}\n"; \
			$(VENV_DIR)/bin/python -m pip install --upgrade pip > /dev/null 2>&1; \
			printf "${GREEN}✅ pip обновлен${NC}\n"; \
			printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
		else \
			printf "${RED}❌ Ошибка при создании виртуального окружения!${NC}\n"; \
			printf "${YELLOW}  Убедитесь, что Python ${PYTHON_REQUIRED} установлен: $(PYTHON_CMD)$(PYTHON_REQUIRED) --version${NC}\n\n"; \
			exit 1; \
		fi \
	else \
		printf "${YELLOW}📁 Виртуальное окружение уже существует в $(VENV_DIR)${NC}\n"; \
		printf "${YELLOW}⚙️ Проверка pip...${NC}\n"; \
		$(VENV_DIR)/bin/python -m pip install --upgrade pip > /dev/null 2>&1; \
		printf "${GREEN}✅ pip готов к работе${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
	fi
	
	@printf "\n${CYAN}📋 СЛЕДУЮЩИЕ ШАГИ:${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"
	
	@printf "${GREEN}1. Активируйте виртуальное окружение:${NC}\n"
	@printf "   ${YELLOW}source $(VENV_DIR)/bin/activate${NC}\n\n"
	
	@printf "${GREEN}2. Установите ${PROJECT_NAME} и зависимости:${NC}\n"
	@printf "   ${YELLOW}make install${NC}\n\n"
	
	@printf "${GREEN}3. Запустите пример и следуйте инструкциям:${NC}\n"
	@printf "   ${YELLOW}make run-connect${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"

# Цель - Установка пакета 
install:
	@printf "\n${CYAN}📦 УСТАНОВКА ${PROJECT_NAME} v${PROJECT_VERSION}${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	@printf "${CYAN}📝 ${PROJECT_DESCRIPTION}${NC}\n"
	@printf "${CYAN}👤 Автор: ${PROJECT_AUTHOR_NAME}${NC}\n"
	@printf "${CYAN}🔗 Репозиторий: ${PROJECT_URL_REPOSITORY}${NC}\n\n"
	
	@printf "${YELLOW}🔧 ПРОВЕРКА ОКРУЖЕНИЯ${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	
	@if ! command -v uv >/dev/null 2>&1; then \
		printf "${YELLOW}⚠️ uv не найден. Устанавливаю...${NC}\n"; \
		pip install uv > /dev/null 2>&1; \
		if [ $$? -eq 0 ]; then \
			printf "${GREEN}✅ uv установлен${NC}\n\n"; \
		else \
			printf "${RED}❌ Не удалось установить uv${NC}\n"; \
			printf "${YELLOW}  Установите uv вручную: pip install uv${NC}\n\n"; \
			exit 1; \
		fi \
	else \
		printf "${GREEN}✅ uv уже установлен${NC}\n\n"; \
	fi
	
	@printf "${YELLOW}🔍 ПРОВЕРКА UV.LOCK${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	@if command -v uv >/dev/null 2>&1; then \
		if [ -f "uv.lock" ]; then \
			printf "${GREEN}  ✓ uv.lock найден${NC}\n"; \
			if uv lock --check > /dev/null 2>&1; then \
				printf "${GREEN}  ✓ uv.lock валиден и соответствует pyproject.toml${NC}\n"; \
				LOCK_VALID=true; \
			else \
				printf "${YELLOW}  ⚠️ uv.lock требует обновления${NC}\n"; \
				LOCK_VALID=false; \
			fi; \
		else \
			printf "${YELLOW}  ⚠️ uv.lock не найден, будет создан при установке${NC}\n"; \
			LOCK_VALID=false; \
		fi; \
		printf "\n"; \
	fi
	
	@VENV_CREATED=0; \
	USE_UV_RUN=0; \
	if [ ! -d "$(VENV_DIR)" ]; then \
		printf "${YELLOW}⚠️ Виртуальное окружение не найдено! ⚠️${NC}\n\n"; \
		printf "${CYAN}Для работы с проектом рекомендуется использовать виртуальное окружение.${NC}\n\n"; \
		printf "${GREEN}1. Создать виртуальное окружение (make venv)${NC}\n"; \
		printf "${GREEN}2. Продолжить установку без виртуального окружения (через uv run)${NC}\n\n"; \
		printf "${YELLOW}Выберите действие (1/2): ${NC}"; \
		read -r choice; \
		if [ "$$choice" = "1" ]; then \
			printf "\n${CYAN}Создаю виртуальное окружение через uv...${NC}\n\n"; \
			$(MAKE) venv; \
			VENV_CREATED=1; \
			printf "\n"; \
			if [ -z "$$VIRTUAL_ENV" ]; then \
				printf "${YELLOW}⚠️ ВНИМАНИЕ: Виртуальное окружение создано, но не активировано! ⚠️${NC}\n\n"; \
				printf "${CYAN}Для продолжения работы рекомендуется активировать окружение:${NC}\n\n"; \
				printf "${GREEN}   source $(VENV_DIR)/bin/activate${NC}\n\n"; \
				printf "${YELLOW}Продолжить установку без активации (через uv run)? (y/n): ${NC}"; \
				read -r choice2; \
				if [ "$$choice2" != "y" ] && [ "$$choice2" != "Y" ]; then \
					printf "${RED}❌ Установка отменена. Активируйте окружение и повторите команду.${NC}\n\n"; \
					exit 1; \
				else \
					printf "${GREEN}✅ Продолжаем установку через uv run...${NC}\n\n"; \
					USE_UV_RUN=1; \
				fi; \
			else \
				printf "${GREEN}✅ Виртуальное окружение создано и активировано!${NC}\n\n"; \
				USE_UV_RUN=0; \
			fi; \
		elif [ "$$choice" = "2" ]; then \
			printf "${YELLOW}⚠️ Продолжаем установку без виртуального окружения (через uv run)...${NC}\n\n"; \
			USE_UV_RUN=1; \
		else \
			printf "${RED}❌ Неверный выбор. Установка отменена.${NC}\n\n"; \
			exit 1; \
		fi; \
	else \
		if [ -z "$$VIRTUAL_ENV" ]; then \
			printf "${YELLOW}⚠️ ВНИМАНИЕ: Виртуальное окружение существует, но не активировано! ⚠️${NC}\n\n"; \
			printf "${CYAN}Активируйте существующее окружение:${NC}\n\n"; \
			printf "${GREEN}   source $(VENV_DIR)/bin/activate${NC}\n\n"; \
			printf "${YELLOW}Продолжить установку без активации (через uv run)? (y/n): ${NC}"; \
			read -r choice; \
			if [ "$$choice" != "y" ] && [ "$$choice" != "Y" ]; then \
				printf "${RED}❌ Установка отменена. Активируйте окружение и повторите команду.${NC}\n\n"; \
				exit 1; \
			else \
				printf "${GREEN}✅ Продолжаем установку через uv run...${NC}\n\n"; \
				USE_UV_RUN=1; \
			fi; \
		else \
			printf "${GREEN}✅ Виртуальное окружение активировано!${NC}\n\n"; \
			USE_UV_RUN=0; \
		fi; \
	fi
	
	@printf "${YELLOW}⚙️ УСТАНОВКА ПРОЕКТА${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	
	@if [ "$$USE_UV_RUN" = "1" ]; then \
		if uv run pip show $(PROJECT_NAME) > /dev/null 2>&1; then \
			CURRENT_VER=$$(uv run pip show $(PROJECT_NAME) | grep Version | awk '{print $$2}'); \
			printf "${GREEN}✅ ${PROJECT_NAME} уже установлен (версия $$CURRENT_VER)${NC}\n"; \
		else \
			printf "${YELLOW}⚠️ ${PROJECT_NAME} не установлен${NC}\n"; \
			printf "${YELLOW}⚙️ Установка ${PROJECT_NAME} v${PROJECT_VERSION} через uv...${NC}\n\n"; \
			if [ "$$LOCK_VALID" = "true" ]; then \
				printf "${GREEN}  Использую существующий uv.lock для синхронизации...${NC}\n"; \
				uv run uv sync; \
			else \
				printf "${YELLOW}  Обновляю uv.lock и синхронизирую...${NC}\n"; \
				uv run uv sync -q; \
			fi; \
			if [ $$? -eq 0 ]; then \
				printf "${GREEN}✅ ${PROJECT_NAME} успешно установлен!${NC}\n"; \
			else \
				printf "\n${RED}❌ Ошибка при установке ${PROJECT_NAME}${NC}\n"; \
				printf "${YELLOW}Попробуйте установить локальную версию:${NC}\n"; \
				printf "  ${YELLOW}uv pip install .${NC}\n\n"; \
				exit 0; \
			fi \
		fi \
	else \
		if uv pip show $(PROJECT_NAME) > /dev/null 2>&1; then \
			CURRENT_VER=$$(uv pip show $(PROJECT_NAME) | grep Version | awk '{print $$2}'); \
			printf "${GREEN}✅ ${PROJECT_NAME} уже установлен (версия $$CURRENT_VER)${NC}\n"; \
		else \
			printf "${YELLOW}⚠️ ${PROJECT_NAME} не установлен${NC}\n"; \
			printf "${YELLOW}⚙️ Установка ${PROJECT_NAME} v${PROJECT_VERSION} через uv...${NC}\n\n"; \
			if [ "$$LOCK_VALID" = "true" ]; then \
				printf "${GREEN}  Использую существующий uv.lock для синхронизации...${NC}\n"; \
				uv sync; \
			else \
				printf "${YELLOW}  Обновляю uv.lock и синхронизирую...${NC}\n"; \
				uv sync -q; \
			fi; \
			if [ $$? -eq 0 ]; then \
				printf "${GREEN}✅ ${PROJECT_NAME} успешно установлен!${NC}\n"; \
			else \
				printf "\n${RED}❌ Ошибка при установке ${PROJECT_NAME}${NC}\n"; \
				printf "${YELLOW}Попробуйте установить локальную версию:${NC}\n"; \
				printf "  ${YELLOW}uv pip install .${NC}\n\n"; \
				exit 0; \
			fi \
		fi \
	fi
	
	@printf "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"
	
	@if [ "$$VENV_CREATED" = "1" ] && [ -z "$$VIRTUAL_ENV" ]; then \
		printf "${YELLOW}📢 ВАЖНОЕ НАПОМИНАНИЕ 📢${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
		printf "${GREEN}✅ Виртуальное окружение создано и библиотеки установлены!${NC}\n\n"; \
		printf "${YELLOW}Для дальнейшей работы с проектом АКТИВИРУЙТЕ окружение:${NC}\n\n"; \
		printf "   ${GREEN}source $(VENV_DIR)/bin/activate${NC}\n\n"; \
		printf "${CYAN}После активации вы сможете запускать примеры командами:${NC}\n"; \
		printf "   ${YELLOW}make run-connect${NC}\n"; \
		printf "   ${YELLOW}make run-ticker${NC}\n"; \
		printf "   ${YELLOW}make run-bars${NC}\n"; \
		printf "   ${YELLOW}make run-accounts${NC}\n\n"; \
		printf "${CYAN}Или используйте uv run без активации:${NC}\n"; \
		printf "   ${YELLOW}uv run python $(EXAMPLES_PATH)/Connect.py${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"; \
	fi
	
	@printf "${MAGENTA}🔑 ВАЖНАЯ ИНФОРМАЦИЯ 🔑${NC}\n"
	@printf "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	@printf "${YELLOW}⚠️ Для первого запуска необходим токен T-Invest API ⚠️${NC}\n\n"
	@printf "1. Получить токен в настройках профиля ${CYAN}\\033]8;;https://www.tinkoff.ru/invest/settings/api\\033\\\\Т-Инвестиций\\033]8;;\\033\\\\${NC}\n"
	@printf "2. Создайте токен с правами ${GREEN}Чтение и Торговля${NC}\n"
	@printf "3. Скопируйте токен в буфер обмена\n"
	@printf "4. Выполните команду ${YELLOW}make run-connect${NC} и следуйте дальнейшим инструкциям\n\n"
	
	@printf "${GREEN}🚀 ${PROJECT_NAME} v${PROJECT_VERSION} ГОТОВ К ИСПОЛЬЗОВАНИЮ!${NC}\n"
	@printf "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"

# Цели - Запуск примеров из папки Examples
run-connect:
	@printf "\n${CYAN}▶️ ПОДГОТОВКА И ЗАПУСК Connect.py...${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"
	
	@printf "${YELLOW}🔑 ПРОВЕРКА ОКРУЖЕНИЯ${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	@if [ -z "$$VIRTUAL_ENV" ]; then \
		printf "${RED}❌ ОШИБКА: Виртуальное окружение не активировано!${NC}\n\n"; \
		printf "${YELLOW}Активируйте окружение:${NC}\n"; \
		printf "  ${GREEN}source $(VENV_DIR)/bin/activate${NC}\n\n"; \
		exit 1; \
	else \
		printf "${GREEN}✅ Виртуальное окружение активировано!${NC}\n\n"; \
	fi
	
	@printf "${YELLOW}🔑 ПРОВЕРКА ТОКЕНА${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	@if [ -n "$(TINVEST_TOKEN)" ]; then \
		printf "${GREEN}✓ Токен получен из аргумента командной строки${NC}\n\n"; \
		TOKEN="$(TINVEST_TOKEN)"; \
		TOKEN_LENGTH=$$(printf "%s" "$$TOKEN" | wc -c | tr -d ' '); \
		printf "📌 Длина: ${YELLOW}%s символов${NC}\n" "$$TOKEN_LENGTH"; \
		printf "📌 Начинается с: ${YELLOW}%s...${NC}\n" "$$(printf "%s" "$$TOKEN" | cut -c1-20)"; \
		printf "📌 Заканчивается на: ${YELLOW}...%s${NC}\n\n" "$$(printf "%s" "$$TOKEN" | rev | cut -c1-20 | rev)"; \
		printf "${YELLOW}💾 Сохраняем токен в keyring...${NC}\n\n"; \
		if python3 -c "import keyring; keyring.set_password('TinvestPy', 'token', '$$TOKEN')" 2>/dev/null; then \
			printf "${GREEN}✅ Токен успешно сохранен в keyring!${NC}\n\n"; \
		else \
			printf "${RED}❌ Ошибка при сохранении токена в keyring${NC}\n"; \
			printf "${YELLOW}  Убедитесь, что keyring настроен корректно${NC}\n\n"; \
		fi; \
	else \
		printf "${YELLOW}🔍 Проверка токена в keyring...${NC}\n\n"; \
		SAVED_TOKEN=$$(python3 -c "import keyring; print(keyring.get_password('TinvestPy', 'token') or '')" 2>/dev/null); \
		if [ -n "$$SAVED_TOKEN" ]; then \
			printf "${GREEN}✓ Найден сохраненный токен в keyring${NC}\n\n"; \
			TOKEN_LENGTH=$$(printf "%s" "$$SAVED_TOKEN" | wc -c | tr -d ' '); \
			printf "📌 Длина: ${YELLOW}%s символов${NC}\n" "$$TOKEN_LENGTH"; \
			printf "📌 Начинается с: ${YELLOW}%s...${NC}\n" "$$(printf "%s" "$$SAVED_TOKEN" | cut -c1-20)"; \
			printf "📌 Заканчивается на: ${YELLOW}...%s${NC}\n\n" "$$(printf "%s" "$$SAVED_TOKEN" | rev | cut -c1-20 | rev)"; \
			printf "${YELLOW}⚠️ Использовать этот токен? (y/n): ${NC}"; \
			read -r USE_SAVED; \
			if [ "$$USE_SAVED" = "y" ] || [ "$$USE_SAVED" = "Y" ]; then \
				printf "\n${GREEN}✓ Будет использован сохраненный токен${NC}\n\n"; \
				TOKEN="$$SAVED_TOKEN"; \
			else \
				printf "\n${YELLOW}✗ Будет введен новый токен${NC}\n\n"; \
				GET_NEW_TOKEN="yes"; \
			fi; \
		else \
			printf "${YELLOW}✗ Токен не найден в keyring${NC}\n\n"; \
			GET_NEW_TOKEN="yes"; \
		fi; \
	fi; \
	\
	if [ "$$GET_NEW_TOKEN" = "yes" ] && [ -z "$$TOKEN" ]; then \
		printf "${YELLOW}❓ ВЫБОР ТИПА ТОКЕНА${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
		printf "${YELLOW}Сколько символов у вашего токена?${NC}\n"; \
		printf "  ${GREEN}1)${NC} Более 1 000 символов (примерно)\n"; \
		printf "  ${GREEN}2)${NC} Менее 1 000 символов (примерно)\n\n"; \
		printf "${YELLOW}Выберите вариант (1/2): ${NC}"; \
		read -r TOKEN; \
		printf "\n"; \
		\
		if [ "$$TOKEN" = "1" ]; then \
			printf "${YELLOW}⚡️ ЗАПУСКАЮ С ТОКЕНОМ...${NC}\n"; \
			printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
			printf "${YELLOW}Запустите команду с токеном:${NC}\n"; \
			printf "  ${GREEN}make run-connect TINVEST_TOKEN='ваш_токен'${NC}\n\n"; \
			exit 0; \
		elif [ "$$TOKEN" = "2" ]; then \
			printf "${YELLOW}📝 ВВОД ТОКЕНА${NC}\n"; \
			printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
			printf "${YELLOW}Вставьте токен и нажмите Enter (символы не отображаются для безопасности):${NC}\n"; \
			printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
			stty -echo; read -r TOKEN; stty echo; \
			printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"; \
			\
			if [ -z "$$TOKEN" ]; then \
				printf "${RED}❌ Токен не может быть пустым${NC}\n\n"; \
				exit 1; \
			fi; \
			\
			printf "${YELLOW}💾 СОХРАНЕНИЕ В KEYRING${NC}\n"; \
			printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
			if python3 -c "import keyring; keyring.set_password('TinvestPy', 'token', '$$TOKEN')" 2>/dev/null; then \
				TOKEN_LENGTH=$$(printf "%s" "$$TOKEN" | wc -c | tr -d ' '); \
				printf "${GREEN}✅ Токен успешно сохранен в keyring!${NC}\n\n"; \
				printf "📌 Длина: ${YELLOW}%s символов${NC}\n" "$$TOKEN_LENGTH"; \
				printf "📌 Начинается с: ${YELLOW}%s...${NC}\n" "$$(printf "%s" "$$TOKEN" | cut -c1-20)"; \
				printf "📌 Заканчивается на: ${YELLOW}...%s${NC}\n\n" "$$(printf "%s" "$$TOKEN" | rev | cut -c1-20 | rev)"; \
			else \
				printf "${RED}❌ Ошибка при сохранении токена в keyring${NC}\n"; \
				printf "${YELLOW}  Убедитесь, что keyring настроен корректно${NC}\n\n"; \
				exit 1; \
			fi; \
		else \
			printf "${RED}❌ Неверный выбор${NC}\n\n"; \
			exit 1; \
		fi; \
	fi; \
	\
	printf "${YELLOW}🚀 ЗАПУСКАЮ Connect.py...${NC}\n"; \
	printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"; \
	cd $(EXAMPLES_PATH) && python3 Connect.py; \
	EXIT_CODE=$$?; \
	printf "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
	if [ $$EXIT_CODE -eq 0 ]; then \
		printf "${GREEN}✅ Запуск Connect.py выполнен успешно!${NC}\n\n"; \
		printf "${CYAN}📚 ДРУГИЕ КОМАНДЫ ДЛЯ ЗАПУСКА ПРИМЕРОВ${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"; \
		printf "  ${YELLOW}make run-ticker${NC}       - Ticker.py (Спецификация тикера)\n"; \
		printf "  ${YELLOW}make run-bars${NC}         - Bars.py (История тикера)\n"; \
		printf "  ${YELLOW}make run-accounts${NC}     - Accounts.py (Все торговые счета, позиции и заявки)\n"; \
		printf "  ${YELLOW}make run-stream${NC}       - Stream.py (Подписка на котировки)\n"; \
		printf "  ${YELLOW}make run-transactions${NC} - Transactions.py (Постановка и снятие заявок)\n\n"; \
	else \
		printf "${RED}❌ Ошибка при выполнении Connect.py${NC}\n\n"; \
		printf "${YELLOW}📝 ДЕЙСТВИЯ ПРИ ОШИБКЕ${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
		printf "${YELLOW}Попробуйте сохранить новый токен в keyring:${NC}\n\n"; \
		printf "  ${GREEN}make run-connect TINVEST_TOKEN='ваш_токен'${NC}\n\n"; \
		exit 0; \
	fi

run-ticker:
	@printf "\n${CYAN}▶️ ЗАПУСКАЮ Ticker.py... (${PROJECT_NAME} v${PROJECT_VERSION})${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"
	@printf "${CYAN}📋 Описание:${NC} Спецификация тикера.\n\n"
	@printf "${YELLOW}⚠️  Убедитесь, что токен установлен при первом запуске ⚠️${NC}\n\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	@printf "${CYAN}Продолжить запуск? (y/n): ${NC}"; \
	read choice; \
	if [ "$$choice" = "y" ] || [ "$$choice" = "Y" ]; then \
		printf "\n${GREEN}🚀 Запускаю Ticker.py...${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"; \
		cd ${EXAMPLES_PATH} && python Ticker.py; \
		printf "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
		printf "${GREEN}✅ Запуск Ticker.py выполнен успешно!${NC}\n\n"; \
		printf "${CYAN}📚 ДРУГИЕ КОМАНДЫ ДЛЯ ЗАПУСКА ПРИМЕРОВ${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"; \
		printf "  ${YELLOW}make run-bars${NC}         - Bars.py (История тикера)\n"; \
		printf "  ${YELLOW}make run-accounts${NC}     - Accounts.py (Все торговые счета, позиции и заявки)\n"; \
		printf "  ${YELLOW}make run-stream${NC}       - Stream.py (Подписка на котировки)\n"; \
		printf "  ${YELLOW}make run-transactions${NC} - Transactions.py (Постановка и снятие заявок)\n"; \
		printf "  ${YELLOW}make run-connect${NC}      - Connect.py (Ввод токена и проверка работы запросов/ответов и подписок)\n\n"; \
	else \
		printf "${YELLOW}⏭️ Запуск отменен${NC}\n\n"; \
	fi

run-bars:
	@printf "\n${CYAN}▶️ ЗАПУСКАЮ Bars.py... (${PROJECT_NAME} v${PROJECT_VERSION})${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"
	@printf "${CYAN}📋 Описание:${NC} История тикера.\n\n"
	@printf "${YELLOW}⚠️  Убедитесь, что токен установлен при первом запуске ⚠️${NC}\n\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	@printf "${CYAN}Продолжить запуск? (y/n): ${NC}"; \
	read choice; \
	if [ "$$choice" = "y" ] || [ "$$choice" = "Y" ]; then \
		printf "\n${GREEN}🔧 ПОДГОТОВКА К ЗАПУСКУ${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"; \
		printf "${YELLOW}🔍 Проверка pandas...${NC}\n"; \
		if python -c "import pandas" 2>/dev/null; then \
			printf "${GREEN}✓ pandas уже установлен${NC}\n"; \
			PANDAS_INSTALLED=0; \
		else \
			printf "${YELLOW}📦 Устанавливаю pandas через uv...${NC}\n"; \
			if uv pip install pandas --quiet > /dev/null 2>&1; then \
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
		printf "${GREEN}🚀 ЗАПУСКАЮ Bars.py...${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"; \
		cd ${EXAMPLES_PATH} && python Bars.py; \
		SCRIPT_EXIT_CODE=$$?; \
		printf "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
		printf "${GREEN}✅ Запуск Bars.py выполнен успешно!${NC}\n\n"; \
		if [ "$$PANDAS_INSTALLED" = "1" ]; then \
			printf "${YELLOW}🗑️ Удаляю pandas через uv...${NC}\n"; \
			yes | uv pip uninstall pandas -q > /dev/null 2>&1 && \
				printf "${GREEN}✓ pandas удален${NC}\n" || \
				printf "${YELLOW}⚠️ Не удалось удалить pandas${NC}\n"; \
			printf "\n"; \
		fi; \
		printf "${CYAN}📚 ДРУГИЕ КОМАНДЫ ДЛЯ ЗАПУСКА ПРИМЕРОВ${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"; \
		printf "  ${YELLOW}make run-accounts${NC}     - Accounts.py (Все торговые счета, позиции и заявки)\n"; \
		printf "  ${YELLOW}make run-stream${NC}       - Stream.py (Подписка на котировки)\n"; \
		printf "  ${YELLOW}make run-transactions${NC} - Transactions.py (Постановка и снятие заявок)\n"; \
		printf "  ${YELLOW}make run-connect${NC}      - Connect.py (Ввод токена и проверка работы запросов/ответов и подписок)\n"; \
		printf "  ${YELLOW}make run-ticker${NC}       - Ticker.py (Спецификация тикера)\n\n"; \
		exit $$SCRIPT_EXIT_CODE; \
	else \
		printf "${YELLOW}⏭️ Запуск отменен${NC}\n\n"; \
	fi

run-accounts:
	@printf "\n${CYAN}▶️ ЗАПУСКАЮ Accounts.py... (${PROJECT_NAME} v${PROJECT_VERSION})${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"
	@printf "${CYAN}📋 Описание:${NC} Все торговые счета, позиции и заявки.\n\n"
	@printf "${YELLOW}⚠️  Убедитесь, что токен установлен при первом запуске ⚠️${NC}\n\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	@printf "${CYAN}Продолжить запуск? (y/n): ${NC}"; \
	read choice; \
	if [ "$$choice" = "y" ] || [ "$$choice" = "Y" ]; then \
		printf "\n${GREEN}🚀 ЗАПУСКАЮ Accounts.py...${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"; \
		cd ${EXAMPLES_PATH} && python Accounts.py; \
		printf "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
		printf "${GREEN}✅ Запуск Accounts.py выполнен успешно!${NC}\n\n"; \
		printf "${CYAN}📚 ДРУГИЕ КОМАНДЫ ДЛЯ ЗАПУСКА ПРИМЕРОВ${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"; \
		printf "  ${YELLOW}make run-stream${NC}       - Stream.py (Подписка на котировки)\n"; \
		printf "  ${YELLOW}make run-transactions${NC} - Transactions.py (Постановка и снятие заявок)\n"; \
		printf "  ${YELLOW}make run-connect${NC}      - Connect.py (Ввод токена и проверка работы запросов/ответов и подписок)\n"; \
		printf "  ${YELLOW}make run-ticker${NC}       - Ticker.py (Спецификация тикера)\n"; \
		printf "  ${YELLOW}make run-bars${NC}         - Bars.py (История тикера)\n\n"; \
	else \
		printf "${YELLOW}⏭️ Запуск отменен${NC}\n\n"; \
	fi

run-stream:
	@printf "\n${CYAN}▶️ ЗАПУСКАЮ Stream.py... (${PROJECT_NAME} v${PROJECT_VERSION})${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"
	@printf "${CYAN}📋 Описание:${NC} Подписка на котировки.\n\n"
	@printf "${YELLOW}⚠️  Убедитесь, что токен установлен при первом запуске ⚠️${NC}\n\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	@printf "${CYAN}Продолжить запуск? (y/n): ${NC}"; \
	read choice; \
	if [ "$$choice" = "y" ] || [ "$$choice" = "Y" ]; then \
		printf "\n${GREEN}🚀 ЗАПУСКАЮ Stream.py...${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"; \
		cd ${EXAMPLES_PATH} && python Stream.py; \
		printf "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
		printf "${GREEN}✅ Запуск Stream.py выполнен успешно!${NC}\n\n"; \
		printf "${CYAN}📚 ДРУГИЕ КОМАНДЫ ДЛЯ ЗАПУСКА ПРИМЕРОВ${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"; \
		printf "  ${YELLOW}make run-transactions${NC} - Transactions.py (Постановка и снятие заявок)\n"; \
		printf "  ${YELLOW}make run-connect${NC}      - Connect.py (Ввод токена и проверка работы запросов/ответов и подписок)\n"; \
		printf "  ${YELLOW}make run-ticker${NC}       - Ticker.py (Спецификация тикера)\n"; \
		printf "  ${YELLOW}make run-bars${NC}         - Bars.py (История тикера)\n"; \
		printf "  ${YELLOW}make run-accounts${NC}     - Accounts.py (Все торговые счета, позиции и заявки)\n\n"; \
	else \
		printf "${YELLOW}⏭️ Запуск отменен${NC}\n\n"; \
	fi

run-transactions:
	@printf "\n${CYAN}▶️ ЗАПУСКАЮ Transactions.py... (${PROJECT_NAME} v${PROJECT_VERSION})${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"
	@printf "${CYAN}📋 Описание:${NC} Постановка и снятие заявок.\n\n"
	@printf "${YELLOW}⚠️  Убедитесь, что токен установлен при первом запуске ⚠️${NC}\n\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	@printf "${CYAN}Продолжить запуск? (y/n): ${NC}"; \
	read choice; \
	if [ "$$choice" = "y" ] || [ "$$choice" = "Y" ]; then \
		printf "\n${GREEN}🚀 ЗАПУСКАЮ Transactions.py...${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"; \
		cd ${EXAMPLES_PATH} && python Transactions.py; \
		printf "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
		printf "${GREEN}✅ Запуск Transactions.py выполнен успешно!${NC}\n\n"; \
		printf "${CYAN}📚 ДРУГИЕ КОМАНДЫ ДЛЯ ЗАПУСКА ПРИМЕРОВ${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"; \
		printf "  ${YELLOW}make run-connect${NC}      - Connect.py (Ввод токена и проверка работы запросов/ответов и подписок)\n"; \
		printf "  ${YELLOW}make run-ticker${NC}       - Ticker.py (Спецификация тикера)\n"; \
		printf "  ${YELLOW}make run-bars${NC}         - Bars.py (История тикера)\n"; \
		printf "  ${YELLOW}make run-accounts${NC}     - Accounts.py (Все торговые счета, позиции и заявки)\n"; \
		printf "  ${YELLOW}make run-stream${NC}       - Stream.py (Подписка на котировки)\n\n"; \
	else \
		printf "${YELLOW}⏭️ Запуск отменен${NC}\n\n"; \
	fi

# Цель - Обновление пакета из GitHub
update:
	@printf "\n${CYAN}🔄 ОБНОВЛЕНИЕ ${PROJECT_NAME} ИЗ GITHUB${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"
	
	@if ! command -v uv >/dev/null 2>&1; then \
		printf "${YELLOW}⚠️ uv не найден. Устанавливаю...${NC}\n"; \
		pip install uv > /dev/null 2>&1; \
		if [ $$? -eq 0 ]; then \
			printf "${GREEN}✅ uv установлен${NC}\n\n"; \
		else \
			printf "${RED}❌ Не удалось установить uv${NC}\n"; \
			printf "${YELLOW}  Установите uv вручную: pip install uv${NC}\n\n"; \
			exit 1; \
		fi \
	else \
		printf "${GREEN}✅ uv уже установлен${NC}\n\n"; \
	fi
	
	@printf "${YELLOW}🔍 ПРОВЕРКА ТЕКУЩЕЙ ВЕРСИИ${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	
	@if [ ! -d "$(VENV_DIR)" ]; then \
		printf "${YELLOW}⚠️ Виртуальное окружение не найдено!${NC}\n\n"; \
		printf "${CYAN}Создаю виртуальное окружение...${NC}\n\n"; \
		$(MAKE) venv; \
		printf "\n"; \
	fi

	@if uv pip show $(PROJECT_NAME) > /dev/null 2>&1; then \
		CURRENT_VER=$$(uv pip show $(PROJECT_NAME) | grep Version | awk '{print $$2}'); \
		AVAILABLE_VER_NORM=$$(echo "$(PROJECT_VERSION)" | sed -E 's/\.0+([1-9])/.\1/g; s/\.0+$$//'); \
		printf "${GREEN}✓ Текущая версия: ${YELLOW}%s${NC}\n" "$$CURRENT_VER"; \
		printf "${GREEN}✓ Доступная версия: ${YELLOW}%s${NC}\n\n" "$$AVAILABLE_VER_NORM"; \
		\
		CURRENT_VER_NORM=$$(echo "$$CURRENT_VER" | sed -E 's/\.0+([1-9])/.\1/g; s/\.0+$$//'); \
		\
		if [ "$$CURRENT_VER_NORM" = "$$AVAILABLE_VER_NORM" ]; then \
			printf "${GREEN}✅ У вас уже установлена актуальная версия ${PROJECT_NAME} v$$CURRENT_VER${NC}\n\n"; \
			printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
			exit 0; \
		else \
			printf "${YELLOW}⚠️ Доступна новая версия: ${GREEN}%s${NC} → ${CYAN}%s${NC}\n\n" "$$CURRENT_VER" "$$AVAILABLE_VER_NORM"; \
			UPDATE_NEEDED="yes"; \
		fi; \
	else \
		printf "${YELLOW}⚠️ ${PROJECT_NAME} не найден в текущем окружении${NC}\n\n"; \
		printf "${YELLOW}⚙️ Выполните установку:${NC}\n"; \
		printf "  ${GREEN}make install${NC}\n\n"; \
		exit 0; \
	fi
	
	@if [ "$$UPDATE_NEEDED" = "yes" ]; then \
		printf "${YELLOW}🔧 ПРОВЕРКА ОКРУЖЕНИЯ${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
		if [ -z "$$VIRTUAL_ENV" ]; then \
			printf "${YELLOW}⚠️ Виртуальное окружение не активировано!${NC}\n"; \
			printf "${CYAN}uv автоматически использует $(VENV_DIR)${NC}\n\n"; \
		else \
			printf "${GREEN}✅ Виртуальное окружение активировано!${NC}\n\n"; \
		fi; \
		\
		printf "${YELLOW}❓ ПОДТВЕРЖДЕНИЕ ОБНОВЛЕНИЯ${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
		printf "${YELLOW}Обновить ${PROJECT_NAME} с версии ${RED}%s${NC} → ${GREEN}%s${NC}? (y/n): " "$$CURRENT_VER" "$$AVAILABLE_VER_NORM"; \
		read choice; \
		if [ "$$choice" != "y" ] && [ "$$choice" != "Y" ]; then \
			printf "${YELLOW}⏭️ Обновление отменено.${NC}\n\n"; \
			exit 0; \
		fi; \
		printf "\n"; \
		\
		printf "${YELLOW}⚙️ ПРОЦЕСС ОБНОВЛЕНИЯ${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
		printf "${YELLOW}Обновление ${PROJECT_NAME} с $$CURRENT_VER до $$AVAILABLE_VER_NORM...${NC}\n\n"; \
		if uv pip install -q --upgrade --force-reinstall git+$(PROJECT_URL_REPOSITORY).git; then \
			NEW_VER=$$(uv pip show $(PROJECT_NAME) | grep Version | awk '{print $$2}'); \
			printf "${GREEN}✅ ${PROJECT_NAME} успешно обновлен!${NC}\n\n"; \
			printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
			printf "${GREEN}📦 ${PROJECT_NAME}: ${RED}%s${NC} → ${GREEN}%s${NC}\n" "$$CURRENT_VER" "$$NEW_VER"; \
			printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"; \
		else \
			printf "\n${RED}❌ Ошибка при обновлении ${PROJECT_NAME}${NC}\n"; \
			printf "${YELLOW}  Попробуйте выполнить:${NC}\n"; \
			printf "  ${GREEN}uv pip install --upgrade --force-reinstall git+$(PROJECT_URL_REPOSITORY).git${NC}\n\n"; \
			exit 1; \
		fi; \
		\
		printf "${CYAN}📦 ИНФОРМАЦИЯ О ПРОЕКТЕ${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
		printf "${CYAN}📦 ${PROJECT_NAME} v$(PROJECT_VERSION)${NC}\n"; \
		printf "${CYAN}📝 ${PROJECT_DESCRIPTION}${NC}\n"; \
		printf "${CYAN}👤 Автор: ${PROJECT_AUTHOR_NAME}${NC}\n"; \
		printf "${CYAN}🔗 Репозиторий: ${PROJECT_URL_REPOSITORY}${NC}\n\n"; \
		printf "${GREEN}✅ Обновление завершено успешно!${NC}\n\n"; \
	fi

# Цель - Очистка временных файлов, файлов с логами и виртуального окружения
clean:
	@printf "\n${CYAN}🗑️ ОЧИСТКА ВРЕМЕННЫХ ФАЙЛОВ ${PROJECT_NAME}${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	@if [ -n "$$VIRTUAL_ENV" ]; then \
		printf "\n${RED}⚠️ ВНИМАНИЕ: Виртуальное окружение активно!${NC}\n\n"; \
		printf "${YELLOW}Путь: $$VIRTUAL_ENV${NC}\n\n"; \
		printf "${CYAN}Перед очисткой рекомендуется деактивировать окружение командой:${NC}\n\n"; \
		printf "  ${GREEN}deactivate${NC}\n\n"; \
		printf "${YELLOW}Продолжить очистку при активном окружении? (y/n): ${NC}"; \
		read choice; \
		if [ "$$choice" != "y" ] && [ "$$choice" != "Y" ]; then \
			printf "${RED}✗ Очистка отменена${NC}\n\n"; \
			exit 0; \
		else \
			printf "\n"; \
			CONTINUE_CLEAN=1; \
		fi \
	else \
		CONTINUE_CLEAN=1; \
	fi; \
	\
	if [ "$$CONTINUE_CLEAN" = "1" ]; then \
		ACTIVE_VENV="$${VIRTUAL_ENV:-}"; \
		\
		printf "\n${YELLOW}🔍 ПОИСК LOG ФАЙЛОВ${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
		LOG_FILES=$$(find ${EXAMPLES_PATH} -name "*.log" -type f 2>/dev/null | wc -l); \
		if [ "$$LOG_FILES" -gt 0 ]; then \
			printf "${YELLOW}⚠️ Найдено log файлов: $$LOG_FILES${NC}\n"; \
			printf "${RED}Удалить все log файлы? (y/n): ${NC}"; \
			read choice; \
			if [ "$$choice" = "y" ] || [ "$$choice" = "Y" ]; then \
				find ${EXAMPLES_PATH} -name "*.log" -type f -delete 2>/dev/null; \
				printf "${GREEN}✓ Log файлы удалены${NC}\n\n"; \
			else \
				printf "${YELLOW}✗ Log файлы сохранены${NC}\n\n"; \
			fi; \
		else \
			printf "${GREEN}✓ Log файлы не найдены${NC}\n\n"; \
		fi; \
		\
		printf "${YELLOW}📁 ВИРТУАЛЬНОЕ ОКРУЖЕНИЕ${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
		if [ -d "$(VENV_DIR)" ]; then \
			printf "${YELLOW}⚠️ Обнаружено виртуальное окружение $(VENV_DIR)${NC}\n\n"; \
			REMOVE_VENV=0; \
			if [ -n "$$ACTIVE_VENV" ] && [ "$$ACTIVE_VENV" = "$(CURDIR)/$(VENV_DIR)" ]; then \
				printf "${RED}  ⚠️ Это окружение активно в текущей сессии!${NC}\n\n"; \
				printf "${CYAN}Для безопасного удаления:${NC}\n"; \
				printf "  1. Деактивируйте окружение командой: ${GREEN}deactivate${NC}\n"; \
				printf "  2. Затем повторите команду очистки\n\n"; \
				printf "${YELLOW}ВНИМАНИЕ: Удаление активного окружения может вызвать ошибки!${NC}\n"; \
				printf "${RED}Продолжить удаление активного окружения? (y/n): ${NC}"; \
				read choice; \
				if [ "$$choice" = "y" ] || [ "$$choice" = "Y" ]; then \
					REMOVE_VENV=1; \
					printf "\n"; \
				else \
					printf "${YELLOW}✗ Удаление $(VENV_DIR) пропущено${NC}\n\n"; \
				fi; \
			else \
				printf "${RED}Удалить виртуальное окружение? (y/n): ${NC}"; \
				read choice; \
				if [ "$$choice" = "y" ] || [ "$$choice" = "Y" ]; then \
					REMOVE_VENV=1; \
					printf "\n"; \
				else \
					printf "${YELLOW}✗ Удаление $(VENV_DIR) пропущено${NC}\n\n"; \
				fi; \
			fi; \
			if [ "$$REMOVE_VENV" = "1" ]; then \
				printf "${YELLOW}Удаляю $(VENV_DIR)...${NC}\n"; \
				rm -rf $(VENV_DIR); \
				printf "${GREEN}✓ Виртуальное окружение удалено${NC}\n\n"; \
			fi; \
		else \
			printf "${GREEN}✓ Виртуальное окружение не найдено${NC}\n\n"; \
		fi; \
		\
		printf "${YELLOW}🧹 ОЧИСТКА КЭША UV${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
		if command -v uv >/dev/null 2>&1; then \
			printf "  ${YELLOW}Кэш uv...${NC}\n"; \
			uv cache clean > /dev/null 2>&1 && \
				printf "${GREEN}✓ Кэш uv очищен${NC}\n" || \
				printf "${YELLOW}⚠️ Не удалось очистить кэш uv${NC}\n"; \
		else \
			printf "${YELLOW}⚠️ uv не установлен, пропускаю очистку кэша${NC}\n"; \
		fi; \
		printf "\n"; \
		\
		printf "${YELLOW}⚙️ АВТОМАТИЧЕСКАЯ ОЧИСТКА${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; \
		printf "  ${YELLOW}Кэш Python...${NC}\n"; \
		find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true; \
		find . -type f -name "*.pyc" -delete 2>/dev/null || true; \
		find . -type f -name "*.pyo" -delete 2>/dev/null || true; \
		printf "  ${YELLOW}Кэш инструментов...${NC}\n"; \
		find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true; \
		find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true; \
		find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true; \
		find . -type d -name ".hypothesis" -exec rm -rf {} + 2>/dev/null || true; \
		printf "  ${YELLOW}Файлы сборки...${NC}\n"; \
		if [ -d "dist" ]; then rm -rf dist; fi; \
		if [ -d "build" ]; then rm -rf build; fi; \
		if [ -d "${PROJECT_NAME}.egg-info" ]; then rm -rf ${PROJECT_NAME}.egg-info; fi; \
		find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true; \
		printf "  ${YELLOW}Отчеты...${NC}\n"; \
		find . -type f -name ".coverage" -delete 2>/dev/null || true; \
		find . -type f -name "coverage.xml" -delete 2>/dev/null || true; \
		find . -type f -name "*.coverage" -delete 2>/dev/null || true; \
		printf "  ${YELLOW}Кэш pip...${NC}\n"; \
		rm -rf ~/.cache/pip 2>/dev/null || true; \
		\
		printf "\n${GREEN}✅ ОЧИСТКА ЗАВЕРШЕНА!${NC}\n"; \
		printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"; \
		\
	fi

# Цель - Информация о проекте
info:
	@printf "\n${CYAN}ℹ️ ИНФОРМАЦИЯ О ПРОЕКТЕ ${PROJECT_NAME}${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	@printf "${GREEN}Название:${NC} ${PROJECT_NAME}\n"
	@printf "${GREEN}Версия:${NC} ${PROJECT_VERSION}\n"
	@printf "${GREEN}Автор:${NC} ${PROJECT_AUTHOR_NAME}\n"
	@printf "${GREEN}Описание:${NC} ${PROJECT_DESCRIPTION}\n"
	@printf "${GREEN}Репозиторий:${NC} ${PROJECT_URL_REPOSITORY}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	
	@printf "\n${CYAN}🐍ТЕХНИЧЕСКАЯ ИНФОРМАЦИЯ:${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	@printf "${GREEN}Зависимости:${NC} ${PROJECT_DEPS}\n"
	@printf "${GREEN}Требуемый Python:${NC} >=${PYTHON_REQUIRED}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	
	@printf "\n${CYAN}📚ПЕРЕД НАЧАЛОМ РАБОТЫ:${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	@printf "${YELLOW}Для первого запуска требуется токен ${CYAN}T-Invest API${NC}\n"
	@printf "${YELLOW}Получить токен можно в настройках профиля ${CYAN}\\033]8;;https://www.tinkoff.ru/invest/settings/api\\033\\\\Т-Инвестиций\\033]8;;\\033\\\\${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	
	@printf "\n${CYAN}🚀КОМАНДЫ ДЛЯ НАЧАЛА РАБОТЫ:${NC}\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
	@printf "1. ${YELLOW}make venv${NC}       ⚙️ Создать виртуальное окружение\n"
	@printf "2. ${YELLOW}make install${NC}    📦Установить ${PROJECT_NAME} и зависимости\n"
	@printf "3. ${YELLOW}make run-connect${NC}🔑Выполнить команду и следовать инструкциям\n"
	@printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"
