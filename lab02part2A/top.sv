virtual class shape;

	protected real width;
	protected real heigth;
	function new( real w, real h);
		width = w;
		heigth = h;
	endfunction : new
	pure virtual function real get_area();
	pure virtual function void print();

endclass : shape 

class rectangle extends shape;

	function new( real w, real h);
		super.new(w, h);
	endfunction : new

	function real get_area();
	    return width*heigth;
	endfunction : get_area

	function void print();
		$display( "Rectangle w=%g h=%g area=%g", width, heigth, width*heigth );
	endfunction : print

endclass : rectangle

class square extends shape;

	function new( real w);
		super.new(w, w);
	endfunction : new	
	
	function real get_area();
		return width*heigth;
	endfunction : get_area

	function void print();
		$display( "Square w=%g h=%g area=%g", width, heigth, width*heigth );
	endfunction : print

endclass : square

class triangle extends shape;
	
	function new( real w, real h);
		super.new(w, h);
	endfunction : new	
	
	function real get_area();
		return width*heigth/2;
	endfunction : get_area

	function void print();
		$display( "Triangle w=%g h=%g area=%g", width, heigth, width*heigth/2 );
	endfunction : print

endclass : triangle

class shape_factory; 

	static function shape make_shape(string shape_type, real w, real h);
		
		triangle triangle_h;
		rectangle rectangle_h;
		square square_h;

		case (shape_type )
			"triangle" : begin				
				triangle_h = new(w, h); 
				shape_reporter#(triangle)::store_shape(triangle_h);
				return triangle_h;
			end
			"rectangle" : begin
				rectangle_h = new(w, h);
				shape_reporter#(rectangle)::store_shape(rectangle_h);
				return rectangle_h;
			end
			"square" : begin
				square_h = new(w);
				shape_reporter#(square)::store_shape(square_h);
				return square_h;
			end
			default : $fatal( 1, {"No such shape: ", shape_type } );						
		endcase
		
	endfunction : make_shape

endclass : shape_factory

class shape_reporter #(type T = shape);
	
	protected static T shape_storage[$];
	protected static real t_area;

	
	static function void store_shape( T sh );
		shape_storage.push_back(sh);
	endfunction : store_shape

	static function void report_shapes();
		t_area = 0;
		foreach ( shape_storage[i] )begin
			shape_storage[i].print();
			t_area += shape_storage[i].get_area();
		end
		$display("Total Area %g \n", t_area );
	endfunction : report_shapes 	
	
endclass : shape_reporter

module top;

	initial begin
		shape shape_h;
		triangle triangle_h;
		rectangle rectangle_h;
				
		int f;
		string fline;
		string current_shape;
	        real w;
		real h;
		
		f = $fopen("lab02part2A_shapes.txt", "r");

		if( f == 0 ) begin
			$display("CANNOT OPEN FILE"); 
		end
		else 
		begin
			while( !$feof(f)) begin
				$fgets(fline, f);
				if( fline != "" )begin
					$sscanf( fline, "%s %g %g", current_shape, w, h); 
					shape_h = shape_factory::make_shape(current_shape , w, h );
				end
			end
		

		end
		$fclose(f);
		shape_reporter#(rectangle)::report_shapes();
		shape_reporter#(square)::report_shapes();
		shape_reporter#(triangle)::report_shapes();
	end

endmodule : top
