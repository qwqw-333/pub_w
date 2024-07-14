import csv
import os
from collections import defaultdict

def read_numbers_from_csv(file_path):
    with open(file_path, mode='r') as file:
        reader = csv.reader(file)
        numbers = {int(row[0]) for row in reader if len(row[0]) == 5 and row[0].isdigit()}
    return numbers

def find_pairs(numbers, decade1, decade2):
    pairs = []
    groups = defaultdict(list)

    for number in numbers:
        last_three_digits = str(number)[-3:]
        decade = str(number)[:2]
        groups[last_three_digits].append((number, decade))

    for last_three, group in groups.items():
        if len(group) > 1:
            for i in range(len(group)):
                for j in range(i + 1, len(group)):
                    num1, dec1 = group[i]
                    num2, dec2 = group[j]
                    if dec1 == decade1 and dec2 == decade2:
                        pairs.append((num1, num2))
                    elif dec1 == decade2 and dec2 == decade1:
                        pairs.append((num2, num1))

    return pairs

def write_pairs_to_csv(pairs, output_file_path):
    with open(output_file_path, mode='w', newline='') as file:
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

    pairs = find_pairs(all_numbers, decade1, decade2)

    # Сортировка пар по первому номеру, затем по второму
    pairs.sort(key=lambda x: (min(x), max(x)))

    # Создаем папку output, если она не существует
    output_dir = 'output'
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    output_file_path = os.path.join(output_dir, f"all_USED_numbers_pairs_{decade1}xxx_{decade2}xxx.csv")
    write_pairs_to_csv(pairs, output_file_path)
    print(f"Найденные пары записаны в файл {output_file_path}")

    # Запрос на очистку папки input
    clear_input = input("Хотите очистить папку 'input'? (да/нет): ").strip().lower()
    if clear_input == 'да':
        clear_input_folder(input_folder)
        print(f"Папка {input_folder} очищена")
    else:
        print(f"Папка {input_folder} не была очищена")

if __name__ == "__main__":
    main()
