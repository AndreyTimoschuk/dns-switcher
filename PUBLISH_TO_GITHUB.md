# 📤 Инструкция по публикации на GitHub

## Шаг 1: Создать новый репозиторий на GitHub

1. Перейти на [GitHub](https://github.com/AndreyTimoschuk)
2. Нажать кнопку **"New"** или **"+"** → **"New repository"**
3. Заполнить данные:
   - **Repository name:** `dns-switcher`
   - **Description:** `🔀 Simple and interactive script to switch DNS servers on Linux systems (Google DNS, Cloudflare DNS, Quad9, Custom DNS)`
   - **Public** ✅ (чтобы все могли скачать)
   - **НЕ добавлять** README, .gitignore, license (у нас уже есть)

4. Нажать **"Create repository"**

## Шаг 2: Подключить локальный репозиторий к GitHub

Выполнить команды в терминале:

```bash
cd /Users/andrei/Desktop/at44/dns-switcher

# Добавить удаленный репозиторий
git remote add origin https://github.com/AndreyTimoschuk/dns-switcher.git

# Проверить, что добавилось
git remote -v

# Отправить код на GitHub
git push -u origin main
```

Если будет ошибка про `master` вместо `main`, выполнить:

```bash
git branch -M main
git push -u origin main
```

## Шаг 3: Настроить описание репозитория

На странице репозитория:
1. Нажать **⚙️ Settings** (справа сверху)
2. В разделе **About** добавить:
   - **Description:** `🔀 Simple and interactive script to switch DNS servers on Linux systems`
   - **Website:** можно оставить пустым
   - **Topics (tags):** `dns`, `linux`, `bash`, `systemd`, `dns-switcher`, `cloudflare`, `google-dns`, `yandex-cloud`, `ubuntu`, `debian`
3. Сохранить

## Шаг 4: Проверить, что все работает

Проверить скачивание скрипта:

```bash
# В новой директории или на другом сервере
wget "https://raw.githubusercontent.com/AndreyTimoschuk/dns-switcher/main/dns-switcher.sh" -O dns-switcher.sh
chmod +x dns-switcher.sh
cat dns-switcher.sh  # проверить, что скачалось
```

## Шаг 5: Добавить бейдж в README (опционально)

Отредактировать файл README.md, добавив в начало:

```markdown
# 🔀 DNS Switcher for Linux

[![GitHub stars](https://img.shields.io/github/stars/AndreyTimoschuk/dns-switcher?style=social)](https://github.com/AndreyTimoschuk/dns-switcher/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/AndreyTimoschuk/dns-switcher?style=social)](https://github.com/AndreyTimoschuk/dns-switcher/network/members)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Language-Bash-green.svg)](https://www.gnu.org/software/bash/)
```

Затем закоммитить:

```bash
git add README.md
git commit -m "Add badges to README"
git push
```

## Шаг 6: Создать релиз (опционально, но рекомендуется)

1. На GitHub перейти в **Releases** → **"Create a new release"**
2. Заполнить:
   - **Tag version:** `v1.0.0`
   - **Release title:** `v1.0.0 - Initial Release`
   - **Description:**
     ```
     🎉 Initial Release of DNS Switcher

     ## Features
     - ✅ Interactive DNS provider selection
     - ✅ Support for Google DNS, Cloudflare DNS, Quad9, and Custom DNS
     - ✅ Automatic backup and restore
     - ✅ Uninstaller included
     - ✅ Persistent across reboots
     - ✅ Works on Ubuntu, Debian, CentOS, and Yandex Cloud VMs

     ## Quick Start
     ```bash
     wget "https://raw.githubusercontent.com/AndreyTimoschuk/dns-switcher/main/dns-switcher.sh" -O dns-switcher.sh && chmod +x dns-switcher.sh && sudo bash dns-switcher.sh
     ```

     See [README.md](https://github.com/AndreyTimoschuk/dns-switcher#readme) for full documentation.
     ```
3. Нажать **"Publish release"**

## Готово! 🎉

Теперь ваш скрипт опубликован и доступен всем!

### Ссылки:
- **Репозиторий:** https://github.com/AndreyTimoschuk/dns-switcher
- **Установка одной командой:**
  ```bash
  wget "https://raw.githubusercontent.com/AndreyTimoschuk/dns-switcher/main/dns-switcher.sh" -O dns-switcher.sh && chmod +x dns-switcher.sh && sudo bash dns-switcher.sh
  ```

### Следующие шаги:

1. **Поделиться проектом:**
   - Написать пост в LinkedIn/Twitter/VK
   - Добавить в awesome-списки на GitHub
   - Рассказать коллегам

2. **Улучшить проект:**
   - Добавить CI/CD (GitHub Actions)
   - Добавить автоматические тесты
   - Добавить поддержку других дистрибутивов

3. **Продвижение:**
   - Добавить в [Awesome Bash](https://github.com/awesome-lists/awesome-bash)
   - Добавить в [Awesome Shell](https://github.com/alebcay/awesome-shell)
   - Создать тему на форумах DevOps

---

**Удачи с проектом! 🚀**
