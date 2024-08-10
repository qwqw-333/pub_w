import csv
import os

def read_numbers_from_csv(file_path):
    try:
        with open(file_path, mode='r', encoding='cp1251') as file:  # Указываем кодировку
            reader = csv.reader(file)
            numbers = {int(row[0]) for row in reader if len(row[0]) == 5 and row[0].isdigit()}
        return numbers
    except UnicodeDecodeError:
        print(f"Ошибка декодирования файла: {file_path}. Попробуйте другую кодировку.")
        return set()

def generate_pairs(decade1, decade2):
    pairs = []
    for last_three in range(1000):  # от 000 до 999
        num1 = int(f"{decade1}{last_three:03}")
        num2 = int(f"{decade2}{last_three:03}")
        pairs.append((num1, num2))
    return pairs

def filter_missing_pairs(pairs, existing_numbers):
    missing_pairs = []
    for num1, num2 in pairs:
        if num1 not in existing_numbers and num2 not in existing_numbers:
            missing_pairs.append((num1, num2))
    return missing_pairs

def write_pairs_to_csv(pairs, output_file_path):
    with open(output_file_path, mode='w', newline='', encoding='utf-8') as file:  # Указываем кодировку
        writer = csv.writer(file)
        for num1, num2 in pairs:
            writer.writerow([num1, num2])

def clear_input_folder(folder_path):
    for file_name in os.listdir(folder_path):
        file_path = os.path.join(folder_path, file_name)
        if os.path.isfile(file_path):
            os.remove(file_path)

def main():
    input_folder = 'input'
    all_numbers = set()  # Используем множество для автоматического удаления дубликатов

    for file_name in os.listdir(input_folder):
        file_path = os.path.join(input_folder, file_name)
        if os.path.isfile(file_path):
            all_numbers.update(read_numbers_from_csv(file_path))

    decade1 = input("Введите первую декаду (первые 2 цифры номера): ")
    decade2 = input("Введите вторую декаду (первые 2 цифры номера): ")

    pairs = generate_pairs(decade1, decade2)
    missing_pairs = filter_missing_pairs(pairs, all_numbers)

    # Создаем папку output, если она не существует
    output_dir = 'output'
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    output_file_path = os.path.join(output_dir, f"free_pairs_numbers_{decade1}xxx_{decade2}xxx.csv")
    write_pairs_to_csv(missing_pairs, output_file_path)
    print(f"Найденные пары, отсутствующие в файлах, записаны в файл {output_file_path}")

    # Запрос на очистку папки input
    clear_input = input("Хотите очистить папку 'input'? (yes/no): ").strip().lower()
    if clear_input == 'yes':
        clear_input_folder(input_folder)
        print(f"Папка {input_folder} очищена")
    else:
        print(f"Папка {input_folder} не была очищена")

if __name__ == "__main__":
    main()
