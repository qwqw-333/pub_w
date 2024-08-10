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

def sort_numbers(numbers):
    return sorted(numbers)

def filter_by_decade(numbers, decade):
    decade_str = str(decade)
    filtered_numbers = [number for number in numbers if str(number).startswith(decade_str)]
    return sorted(filtered_numbers)

def write_numbers_to_csv(numbers, output_file_path):
    with open(output_file_path, mode='w', newline='', encoding='utf-8') as file:  # Указываем кодировку
        writer = csv.writer(file)
        for number in numbers:
            writer.writerow([number])

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

    sorted_numbers = sort_numbers(all_numbers)

    while True:
        decade = input("Введите интересующую декаду (первые 2 цифры номера): ")
        filtered_sorted_numbers = filter_by_decade(sorted_numbers, decade)

        # Создаем папку output, если она не существует
        output_dir = 'output'
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)

        output_file_path = os.path.join(output_dir, f"all_used_numbers_{decade}xxx.csv")
        write_numbers_to_csv(filtered_sorted_numbers, output_file_path)
        print(f"Результаты записаны в файл {output_file_path}")

        repeat = input("Хотите ввести другую декаду? (yes/no): ").strip().lower()
        if repeat != 'yes':
            break

    # Запрос на очистку папки input
    clear_input = input("Хотите очистить папку 'input'? (yes/no): ").strip().lower()
    if clear_input == 'yes':
        clear_input_folder(input_folder)
        print(f"Папка {input_folder} очищена")
    else:
        print(f"Папка {input_folder} не была очищена")

if __name__ == "__main__":
    main()
