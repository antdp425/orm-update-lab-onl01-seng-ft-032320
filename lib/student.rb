require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id 

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = "
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      );
    "

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "
      DROP TABLE students
    "
    
    DB[:conn].execute(sql)
  end

  def self.create(name, grade)
    student = Student.new(name,grade) #create new student
    student.save #save student on condition that it doesn't exist (by ID)
    student #return it
  end
  
  def save
    if self.id #if this unique ID / object exists 
      self.update #update it 
    else #otherwise, add it 
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade) 
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
      sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.new_from_db(row)
    student = self.create(row[1],row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    Student.new(result[0], result[1], result[2])
  end

end
