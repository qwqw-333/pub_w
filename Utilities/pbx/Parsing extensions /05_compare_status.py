import os


def read_numbers(file_path):
    with open(file_path, 'r') as file:
        return {line.split(',')[0]: line.split(',')[1].strip() for line in file}


def find_unique_numbers(file1_numbers, file2_numbers):
    differences = []

    for number, status1 in file1_numbers.items():
        status2 = file2_numbers.get(number)
        if status2 and status1 != status2:
            differences.append(f"{number} - enable: {status1} на первом, enable: {status2} на втором")

    for number, status2 in file2_numbers.items():
        if number not in file1_numbers:
            differences.append(f"{number} - отсутствует на первом, {status2} на втором")

    return sorted(differences)


def find_missing_in_file2(file1_numbers, file2_numbers):
    missing = [number for number in file1_numbers.keys() if number not in file2_numbers]
    return sorted(missing, key=int)  # Сортировка номеров по возрастанию


def save_to_file(filename, differences, missing_in_file2):
    with open(filename, 'w') as file:
        file.write("Номера, у которых отличается статус extentions:\n")
        for diff in differences:
            file.write(diff + '\n')

        file.write("\nНомера, которые есть в первом файле, но отсутствуют во втором:\n")
        for number in missing_in_file2:
            file.write(number + '\n')


def main():
    folder = 'input'
    output_folder = 'output'
    output_filename = 'compare_status.txt'

    # Заранее определенные имена файлов
    file1_name = 'kv_extension_export_2024-08-07.csv'
    file2_name = 'lv_extension_export_2024-08-07.csv'

    file1_path = os.path.join(folder, file1_name)
    file2_path = os.path.join(folder, file2_name)
    output_path = os.path.join(output_folder, output_filename)

    file1_numbers = read_numbers(file1_path)
    file2_numbers = read_numbers(file2_path)

    differences = find_unique_numbers(file1_numbers, file2_numbers)
    missing_in_file2 = find_missing_in_file2(file1_numbers, file2_numbers)

    print("\nНомера, у которых отличается статус extentions:")
    for diff in differences:
        print(diff)

    print("\nНомера, которые есть в первом файле, но отсутствуют во втором:")
    for number in missing_in_file2:
        print(number)

    # Запись результатов в файл
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    save_to_file(output_path, differences, missing_in_file2)
    print(f"\nРезультаты сохранены в файл: {output_path}")


if __name__ == "__main__":
    main()
