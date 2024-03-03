import csv
from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker('id_ID')

# Initialize counters for IDs
book_counter = 0
category_counter = 0
library_counter = 0
user_counter = 0

# Generate fake data for the Books table
def generate_books(num_books):
    global book_counter
    books = []
    for _ in range(num_books):
        book_counter += 1
        book = {
            'book_id': int(book_counter),
            'title': fake.sentence(nb_words=4),
            'author': fake.name(),
            'library_id': random.randint(1, 10),  # Assuming you have 10 libraries
            'category_id': random.randint(1, 5),  # Assuming you have 5 categories
            'quantity': random.randint(0, 20)     # Random quantity
        }
        books.append(book)
    return books

# Generate fake data for the Categories table
def generate_categories():
    global category_counter
    categories = [
        {'category_id': int(category_counter + 1), 'name': 'Self-Improvement'},
        {'category_id': int(category_counter + 2), 'name': 'Biography'},
        {'category_id': int(category_counter + 3), 'name': 'Fantasy'},
        {'category_id': int(category_counter + 4), 'name': 'Romance'},
        {'category_id': int(category_counter + 5), 'name': 'Science Fiction'}
    ]
    category_counter += 5
    return categories

# Generate fake data for the Libraries table
def generate_libraries(num_libraries):
    global library_counter
    libraries = []
    for _ in range(num_libraries):
        library_counter += 1
        library = {
            'library_id': int(library_counter),
            'library_name': fake.company(),
            'address': fake.address()
        }
        libraries.append(library)
    return libraries

# Generate fake data for the Users table
def generate_users(num_users):
    global user_counter
    users = []
    for _ in range(num_users):
        user_counter += 1
        user = {
            'user_id': int(user_counter),
            'name': fake.name(),
            'username': fake.user_name(),
            'password': fake.password(),
            'address': fake.address(),
            'BOD': fake.date_of_birth(minimum_age=18, maximum_age=90),
            'Gender': random.choice(['Male', 'Female'])
        }
        users.append(user)
    return users

def generate_loan_systems(num_records):
    loan_systems = []
    loan_counter=0
    for _ in range(num_records):
        loan_counter=loan_counter+1
        
        user_id = random.randint(1, 50)  # Assuming you have 50 users
        book_id = random.randint(1, 100)  # Assuming you have 100 books
        created_at = fake.date_time_between(start_date='-30d', end_date='now')
        borrow_date = created_at + timedelta(days=random.randint(1, 14))  # Borrow date is within 14 days from creation
        max_return_date = borrow_date + timedelta(days=14)  # Two weeks maximum from borrow date
        return_date = fake.date_time_between(start_date=borrow_date, end_date=max_return_date)
        quantity = random.randint(1, 5)  # Random quantity
        loan_system = {
            'loan_id':int(loan_counter),
            'user_id': user_id,
            'book_id': book_id,
            'created_at': created_at,
            'borrow_date': borrow_date,
            'return_date': return_date,
            'quantity': quantity
        }
        loan_systems.append(loan_system)
    return loan_systems

# Save data to CSV
def save_to_csv(data, filename):
    with open(filename, 'w', newline='') as csvfile:
        fieldnames = data[0].keys()
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames, delimiter=',')
        writer.writeheader()
        for row in data:
            writer.writerow(row)

# Generate and save fake data
num_books = 100
num_users = 50
num_libraries = 10
num_loan = 10

books_data = generate_books(num_books)
categories_data = generate_categories()
libraries_data = generate_libraries(num_libraries)
users_data = generate_users(num_users)
loan_data = generate_loan_systems(num_loan)

save_to_csv(books_data, 'books.csv')
save_to_csv(categories_data, 'categories.csv')
save_to_csv(libraries_data, 'libraries.csv')
save_to_csv(users_data, 'users.csv')
save_to_csv(loan_data, 'loan_systems.csv')

print("CSV files generated successfully.")
