
## Creating a Trigger



```
CREATE TRIGGER salary_check
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION check_salary();
```


