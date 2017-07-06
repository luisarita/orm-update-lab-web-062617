require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]  

  attr_reader :grade
  attr_accessor :id, :name

  def initialize(name, grade)
    @name, @grade = name, grade
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY, name TEXT, grade TEXT);"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students;"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    new_student = self.new(row[1], row[2])
    new_student.id = row[0]
    new_student
  end

  def insert
    sql = "INSERT INTO students (name, grade) VALUES (?, ?);"
    DB[:conn].execute(sql, @name, @grade)
    sql = "SELECT last_insert_rowid()"
    @id = DB[:conn].execute(sql)[0][0]
  end

  def update
    sql = "UPDATE students SET name=?, grade=? WHERE id=?"
    DB[:conn].execute(sql, @name, @grade, @id)
  end

  def persisted?
    !!@id
  end
  def save
    if persisted?
      update
    else
      insert
    end
  end
  
  def self.create(values)
    self.create(values[:name], values[:grade])
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
    new_student
  end

  #limit refers to the amount of records to return, set it to 0 for all
  def self.get_students(condition = "", limit = 0, *values)
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql = "SELECT id, name, grade FROM students"
    sql += " WHERE #{condition}" unless condition == ""
    sql += " LIMIT #{limit}" unless limit == 0
    rows = DB[:conn].execute(sql, values)
    rows.collect do |row|
      new_from_db(row)
    end
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    students = get_students("name=?", 0, name)
    
    #we'll return the first one to pass the test
    #but this is not necessarilly correct as more than one student can have the same name
    students[0]
  end
  

  
end
