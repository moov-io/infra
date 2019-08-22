## Prometheus

### Finding most popular metric series

Prometheus can run out of memory if there are too many series for it to track and the memory given is too low for initialization in memory. To inspect the most popular series run the following:

```
topk(10, count by (__name__)({__name__=~".+"}))
```

![](images/popular-metrics.png)

Source: https://www.robustperception.io/which-are-my-biggest-metrics
