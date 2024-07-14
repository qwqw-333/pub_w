import csv
import os


def read_numbers_from_csv(file_path):
    with open(file_path, mode='r') as file:
        reader = csv.reader(file)
        return {int(row[0]) for row in reader if row and row[0].isdigit()}


def generate_all_numbers_for_decade(decade):
    return set(range(int(f"{decade}000"), int(f"{decade}999") + 1))


def write_numbers_to_csv(numbers, output_file_path):
    with open(output_file_path, mode='w', newline='') as file:
        writer = csv.writer(file)
        for number in sorted(numbers):
            writer.writerow([number])


def main():
    decade = input("Введите интересующую декаду (первые 2 цифры номера): ")

    # Чтение используемых номеров
#    used_numbers_file = f"output/all_used_numbers_{decade}xxx.csv"
    used_numbers_file = input("Введите путь к файлу с используемыми номерами: ")
    used_numbers = read_numbers_from_csv(used_numbers_file)

    # Чтение используемых парных номеров
    used_pairs_file = input("Введите путь к файлу с используемыми парными номерами: ")
    used_pairs = read_numbers_from_csv(used_pairs_file)

    # Чтение свободных парных номеров
    free_pairs_file = input("Введите путь к файлу со свободными парными номерами: ")
    free_pairs = read_numbers_from_csv(free_pairs_file)

    # Генерация всех возможных номеров для декады
    all_numbers = generate_all_numbers_for_decade(decade)

    # Нахождение полностью свободных номеров
    free_numbers = all_numbers - used_numbers - used_pairs - free_pairs

    # Создаем папку output, если она не существует
    output_dir = 'output'
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Запись результатов в файл
    output_file_path = os.path.join(output_dir, f"free_solo_numbers_{decade}xxx.csv")
    write_numbers_to_csv(free_numbers, output_file_path)
    print(f"Полностью свободные номера записаны в файл {output_file_path}")
    print(f"Количество полностью свободных номеров: {len(free_numbers)}")


if __name__ == "__main__":
    main()