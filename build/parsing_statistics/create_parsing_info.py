def parse_recipe_times(file_path):
    layer_times = {}

    with open(file_path, 'r') as file:
        for line in file:
            recipe_path, time_str = line.split(':')
            parse_time = float(time_str.split()[0])

            parts = recipe_path.split('/')
            layer_index = None
            for i, part in enumerate(parts):
                if 'meta' in part:
                    layer_index = i
                    break

            layer = parts[layer_index] if layer_index and layer_index < len(parts) else 'unknown'

            if layer in layer_times:
                layer_times[layer] += parse_time
            else:
                layer_times[layer] = parse_time

    return layer_times


def write_layer_times(layer_times, output_file):
    with open(output_file, 'w') as file:
        for layer, time in layer_times.items():
            file.write(f'{layer}: {time:.2f} seconds\n')


if __name__ == '__main__':
    input_file = 'recipe_parsing_time.log'
    output_file = 'layer_parsing_time.log'

    layer_times = parse_recipe_times(input_file)
    write_layer_times(layer_times, output_file)
