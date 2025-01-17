SELECT	book.book_id, author.author_name, book_language.language_code,
		book_language.language_name, book.title, book.isbn13, book.num_pages,
		book.publication_date, publisher.publisher_name
FROM     author INNER JOIN
                  book_author ON author.author_id = book_author.author_id INNER JOIN
                  book ON book_author.book_id = book.book_id INNER JOIN
                  book_language ON book.language_id = book_language.language_id INNER JOIN
                  publisher ON book.publisher_id = publisher.publisher_id