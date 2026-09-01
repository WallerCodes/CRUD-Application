using System;
using System.Collections.Generic;
using System.Text;

/// <summary>
/// Summary description for UsanLinqExtensions
/// </summary>
public static class UsanLinqExtensions
{
    public static void ForEach<K, V>(this Dictionary<K, V> dictionary, Action<K, V> action)
    {
        foreach (KeyValuePair<K, V> entry in dictionary)
        {
            action.Invoke(entry.Key, entry.Value);
        }
    }

    public static void ForEach<V>(this IEnumerable<V> me, Action<V> action)
    {
        foreach (V el in me)
        {
            action.Invoke(el);
        }
    }

    public static void ForEach<V>(this IEnumerable<V> me, Action<V, int> action)
    {
        int i = 0;
        foreach (V el in me)
        {
            action.Invoke(el, i++);
        }
    }

    public static void AddRange<K, V>(this IDictionary<K, V> dictionary, IDictionary<K, V> toAdd)
    {
        foreach (KeyValuePair<K, V> entry in toAdd)
        {
            if (dictionary.ContainsKey(entry.Key))
            {
                dictionary[entry.Key] = entry.Value;
            }
            else
            {
                dictionary.Add(entry.Key, entry.Value);
            }
        }
    }

    public static string Join<E>(this IEnumerable<E> list, string sep)
    {
        StringBuilder str = new StringBuilder();
        bool first = true;
        foreach (E el in list)
        {
            if (!first)
            {
                str.Append(sep);
            }
            str.Append(el.ToString());
            first = false;
        }
        return str.ToString();
    }
}
